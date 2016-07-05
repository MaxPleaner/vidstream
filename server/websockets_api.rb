require 'active_support/all'

class WebsocketsAPI

  attr_reader :vidstream_in, :vidstream_out
  def initialize(vidstream_io)
    @vidstream_in, @vidstream_out = vidstream_io
  end

  def on_open(ws, settings)
    settings.sockets << ws
  end

  def on_close(ws, settings)
    settings.sockets.delete(ws)
  end

  def on_message(ws, settings, msg)
    msg_parts = msg.split(" ")
    case (metacommand = msg_parts.shift)
    when "browser_cmd"
      vidstream_cmd = "browser_cmd " + msg_parts.join(" ") + "\n"
      puts "SENDING CMD TO VIDSTREAM: #{vidstream_cmd}"
      vidstream_in.write(vidstream_cmd)
      scrapped_line = vidstream_out.gets # scrap a line
      vid_url = vidstream_out.gets || ""
      vid_url = vid_url.split("public/")[-1].
                        split("\r\n")[0]
      EM.next_tick { settings.sockets.each{|s| s.send(vid_url) } }
    when "add_word"
      type = msg_parts.shift
      name = msg_parts.shift
      action = msg_parts.shift
      record = type.capitalize.constantize.create(
        name: name,
        action: action
      )
      vidstream_cmd = "add_word #{type} #{record.attributes.to_json} \n"
      puts "SENDING CMD TO VIDSTREAM: #{vidstream_cmd}"
      vidstream_in.write(vidstream_cmd)
      vidstream_in.write("add_word #{type} #{record.attributes.to_json}")
      scrapped_line = vidstream_out.gets
      scrapped_response = vidstream_out.gets
    when "remove_word"
      type = msg_parts.shift
      name = msg_parts.shift
      records = type.capitalize.constantize.all(name: name)
      records.each(&:destroy)
      vidstream_cmd = "remove_word #{type} #{name} \n"
      puts "SENDING CMD TO VIDSTREAM: #{vidstream_cmd}"
      vidstream_in.write(vidstream_cmd)
      scrapped_line = vidstream_out.gets
      scrapped_response = vidstream_out.gets
    else
      error = "INVALID METACOMMAND: #{metacommand}"
      EM.next_tick { settings.sockets.each{|s| s.send(error) } }
    end
  end

end