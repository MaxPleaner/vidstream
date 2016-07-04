class SinatraServer

  # EventMachine needs to be running for the Websockets to work
  def self.ensure_em
    unless EventMachine.reactor_running? && EventMachine.reactor_thread.alive?
      Thread.new { EventMachine.run }
      sleep 1
    end
  end
  
  def self.init_websocket(request, settings, vidstream_io)
    ensure_em
    request.websocket do |ws|
      socket_api = WebsocketsAPI.new(vidstream_io)
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
  
end
