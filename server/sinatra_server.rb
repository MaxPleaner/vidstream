
# Helpers for the Sinatra server relating to websockets
# Does not inherit from Sinatra or contain REST routes.
class SinatraServer

  # EventMachine needs to be running for the Websockets to work
  def self.ensure_em
    unless EventMachine.reactor_running? && EventMachine.reactor_thread.alive?
      Thread.new { EventMachine.run }
      sleep 1
    end
  end
  
  # Start the server-side websocket listeners.
  # There are only three websocket events that watched:
  # - "open":    when a connection is open, store a reference to the open socket
  # - "close":   when a connection closes, delete the stored reference to the socket
  # - "message": when the server receives a message, parse the message and decide how to react.
  def self.init_websocket(request, settings, vidstream_io)
    
    # Start the EventMachine process if it's not already started
    ensure_em
    
    # Check that this request is made over ws:// protocol and raise an error otherwise
    unless request.websocket?
      raise(StandardError, "request is not over websocket protocol, can't get socket")
    end
    
    # Get the websocket object of the request
    request.websocket do |ws|
      
      # Use instancemethods of WebsocketsAPI as the callbacks for events
      # See server/websockets_api.rb
      socket_api = WebsocketsAPI.new(vidstream_io)
      
      # Define callbacks for the open, close, and message events
      ws.onopen { socket_api.on_open(ws, settings) }
      ws.onclose { socket_api.on_close(ws, settings) }
      ws.onmessage { |msg| socket_api.on_message(ws, settings, msg) }
    end
  end
  
end
