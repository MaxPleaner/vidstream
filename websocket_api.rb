class WebsocketAPI
  

  # Stars websocket listeners. Should be called from a route requested over websockets.
  def self.init_websocket(request, settings, vidstream_io)
    ensure_em
    request.websocket do |ws|
      socket_api = new(vidstream_io)
      ws.onopen do
        socket_api.on_open(ws, settings)
      end
      ws.onclose do
        socket_api.on_close(ws, settings)
      end
      ws.onmessage do |msg|
        socket_api.on_message(ws, settings, msg)
      end
    end
  end

  # sinatra-websocket uses EventMachine. This method makes sure it's running.
  def self.ensure_em
    unless EventMachine.reactor_running? && EventMachine.reactor_thread.alive?
      Thread.new { EventMachine.run }
      sleep 1
    end
  end
  
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
    vidstream_in.write(msg + "\n") # vidstream will interpret the command
    scrapped_line = vidstream_out.gets # scrap a line
    vid_path = vidstream_out.gets || "" # capture vidstream out (a filepath)
    send_video(vid_path, settings)
  end

  def send_video(vid_path, settings)
    vid_url = vid_path.split("public/")[-1].split("\r\n")[0]
    EM.next_tick { settings.sockets.each{|s| s.send(vid_url) } }
  end

end
