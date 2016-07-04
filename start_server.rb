require 'sinatra/base'
require 'sinatra-websocket'
require 'pty'
require 'expect'
require 'byebug'

require "./server/external_command_runner"
require "./server/sinatra_server"
require "./server/websockets_api"

if __FILE__ == $0

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

end