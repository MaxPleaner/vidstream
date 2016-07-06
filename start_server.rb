#!/usr/bin/env ruby

# gems
require 'sinatra/base'      # webserver
require 'sinatra-websocket' # realtime
require 'data_mapper'       # Database ORM
require 'eventmachine'      # concurrent process handler
require 'byebug'            # debugger

# stdlib
require 'pty'    # virtual process
require 'expect' # timeout virtual process

require "./server/external_command_runner" # commmand to start the external vidstream process
require "./server/sinatra_server"          # helpers for the sinatra server to init websockets
require "./server/database"                # DataMapper and SQLite
require "./server/websockets_api"          # Websocket router

# Run this block if the script is executed directly (not required)
if __FILE__ == $0

  # An external command to open the vidstream program
  vidstream_cmd = ExternalCommandRunner::VidStreamCmd
  
  # Run the external program and maintain access to its STDIN and STDOUT
  ExternalCommandRunner.with_process_io(vidstream_cmd) do |input, output|
    $vidstream_io = [input, output]
    
    # Define a sinatra app in the modular style
    class MyApp < Sinatra::Base
      set :server, 'thin'
      set :sockets, []
      get '/' do # only one route
        if request.websocket?
          # The client has requested a websocket connection
          # Init the server-side websocket listeners, which act as controllers here.
          # See server/websocket_api.rb
          SinatraServer.init_websocket(request, settings, $vidstream_io)
        else
          # The client has requested a html page
          erb :root
        end
      end
    end
    # Start the Sinatra server
    MyApp.run!
  end
end
