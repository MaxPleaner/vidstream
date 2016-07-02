require 'sinatra/base'
require 'sinatra-websocket'
require 'pty'
require 'expect'
require 'byebug'

class SinatraServer
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
      vidstream_in.write(msg + "\n")
      scrapped_line = vidstream_out.gets # scrap a line
      vid_url = vidstream_out.gets || ""
      vid_url = vid_url.split("public/")[-1].
                        split("\r\n")[0]
      EM.next_tick { settings.sockets.each{|s| s.send(vid_url) } }
    end
  end
end

module ExternalCommandRunner
  VidStreamCmd = "ruby vid_stream.rb"
  
  def self.with_process_io(cmd, &blk)
    PTY.spawn(VidStreamCmd) do |output, input|
      blk.call(input, output)
    end
  end
end


vidstream_cmd = ExternalCommandRunner::VidStreamCmd

ExternalCommandRunner.with_process_io(vidstream_cmd) do |input, output|
  $vidstream_io = [input, output]
  class MyApp < Sinatra::Base
    set :server, 'thin'
    set :sockets, []
    get '/' do
      if request.websocket?
        SinatraServer.init_websocket(request, settings, $vidstream_io)
      else
        erb :root
      end
    end
  end
  MyApp.run!
end
