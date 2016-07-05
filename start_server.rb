require 'sinatra/base'
require 'sinatra-websocket'
require 'pty'
require 'expect'
require 'data_mapper'
require 'eventmachine'
require 'byebug'
require 'faye'

require "./server/external_command_runner"
require "./server/sinatra_server"
require "./server/websockets_api"
require "./server/database"
require "./server/faye_client"

# Start Faye Server
# FayeProcess = Thread.new { `cd faye && rackup` }
FayeProcess = Thread.new {}
at_exit { FayeProcess.kill }

begin

FayeClient.start

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

rescue StandardError => e
  puts e
  puts e.message
  puts e.backtrace
  
ensure
  FayeProcess.kill
  
end