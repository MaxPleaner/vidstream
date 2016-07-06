require 'active_support/all'

require_relative './commands' # on_message callback functions

class WebsocketsAPI
  
  include Commands # server/commands.rb has the definitions for the various commands
                   # This file is more of a router

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
      browser_command(ws, settings, msg_parts.join(" ").gsub("\n", " "))

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
 

end