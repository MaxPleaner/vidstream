require 'active_support/all'

class WebsocketsAPI

  # Maintain access to the external command's i/o
  attr_reader :vidstream_in, :vidstream_out
  def initialize(vidstream_io)
    @vidstream_in, @vidstream_out = vidstream_io
  end

  # Callback when a websocket connection opens
  def on_open(ws, settings)
    settings.sockets << ws
  end

  # Callback when a websocket connection closes
  def on_close(ws, settings)
    settings.sockets.delete(ws)
  end

 # Callback when a message is sent to the server
  def on_message(ws, settings, msg)
    
    # The first word of any message is expected to be a specific command (see the below case statement)
    # The specifications for the rest of the message depend on which case is being run.
    msg_parts = msg.split(" ")
    
    case (metacommand = msg_parts.shift)
    
    when "browser_cmd"
      # Command to run code on headless browser and save video to file
      # Rest of arguments are interpeted by the CommandInterpreter class in the vidstream process
      # Example: "browser_cmd visit google" IF google is defined as a noun AND visit as a verb.
      browser_cmd(ws, settings, msg_parts.join(" ").gsub("\n", " "))

    when "add_word"
      # Add a word to the lexicon
      # First argument is a word type, either 'verb' or 'noun'. Second argument is a name, and third is a Proc
      # Example: "add_word noun ask ->(){'http://ask.com'}"
      add_word(ws, settings, msg_parts.shift, msg_parts.shift, msg_parts.shift)

    when "remove_word"
      # Remove a word from the lexicon
      # First argument is a word type, either 'verb' or 'noun'. Second argument is a name.
      # Example: "remove_word noun ask"
      remove_word(ws, settings, msg_parts.shift, msg_parts.shift)

    else
      error = "INVALID METACOMMAND: #{metacommand}"
      EM.next_tick { settings.sockets.each{|s| s.send(error) } }
    end
  end
  
  # When the client sends a message beginning with "browser_cmd"
  # This will interpret the rest of the command as verb=>noun phrases
  # and run each command in the scope of a headless Selenium browser.
  # The output is saved to video, the filepath of which  is subsequently sent to clients as a websocket message.
  def browser_command(ws, settings, cmd_string)
      
      # Write the command to the vidstream process
      vidstream_cmd = "browser_cmd " + cmd_string + "\n"
      puts "SENDING CMD TO VIDSTREAM: #{vidstream_cmd}"
      vidstream_in.write(vidstream_cmd)
      
      # Scrap a line which is just the input being echoed
      scrapped_line = vidstream_out.gets
      
      # The vidstream process will return a filepath
      vid_url = vidstream_out.gets || ""
      
      # Parse the returned filepath into something usable by the browser
      vid_url = vid_url.split("public/")[-1].
                        split("\r\n")[0]
      
      # Send the message to all connected clients
      EM.next_tick { settings.sockets.each{|s| s.send(vid_url) } }
  end
  
  # Add a word to the Lexicon.
  # Creates a database record
  # Both the vidstream process and this sinatra server access the same database,
  # but the vidstream process needs to be alerted that it should refresh its in-memory lexicon.
  # So this method sends a message that there was a new word added.
  def add_word(ws, settings, type, name, action)
    
    # Use activesupport to turn a string into a reference to a class.
    # i.e. 'verb' becomes Verb
    # Then create a record in the database
    record = type.capitalize.constantize.create(
      name: name,
      action: action
    )
    
    # Craft a command to send to the vidstream process
    vidstream_cmd = "add_word #{type} #{name}#{action} \n"
    puts "SENDING CMD TO VIDSTREAM: #{vidstream_cmd} "
    vidstream_in.write(vidstream_cmd)
    
    # scrap a line of output which is just the input being echoed
    scrapped_line = vidstream_out.gets
    
    # the response will be a JSON representation of the new word, which is discarded.
    scrapped_response = vidstream_out.gets
  end
  
  # Remove a word from the lexicon
  # Removes it from the database.
  # Sends a message to the vidstream process that the in-memory lexicon
  # should be updated to reflect the shared database's state
  def remove_word(ws, settings, type, name)
    
    # find the matching record in the database and destroy it
    records = type.capitalize.constantize.all(name: name)
    records.each(&:destroy)
    
    # send an alert to the vidstream process
    vidstream_cmd = "remove_word #{type} #{name} \n"
    puts "SENDING CMD TO VIDSTREAM: #{vidstream_cmd}"
    vidstream_in.write(vidstream_cmd)
    
    # scrap a line of output which is just the input being echoed
    scrapped_line = vidstream_out.gets
    
    # The response will be a JSON representation of the deleted word, which is discarded.
    scrapped_response = vidstream_out.gets
  end

 

end