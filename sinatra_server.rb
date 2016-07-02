require 'sinatra/base'
require 'sinatra-websocket'
require 'pty'
require 'expect'
require 'byebug'

require './websocket_api'
require './external_command_runner'

# The headless server is running in an external script.
# Communication is done through text i/o

def with_vidstream_io(&blk)
  vidstream_cmd = ExternalCommandRunner::VidStreamCmd
  ExternalCommandRunner.with_process_io(vidstream_cmd) do |input, output|
    $vidstream_io = [input, output] # Set global $vidstream_io object
    blk.call
  end
end

class MyApp < Sinatra::Base
  set :show_exceptions, true
  set :server, 'thin'
  set :sockets, []
  get '/' do
    if request.websocket?
      WebsocketAPI.init_websocket(request, settings, $vidstream_io)
    else
      erb :root
    end
  end
end

if __FILE__ == $0
  # start the server
  with_vidstream_io { MyApp.run! }
end
