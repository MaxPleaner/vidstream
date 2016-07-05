require 'faye'
require 'permessage_deflate'

Faye::WebSocket.load_adapter('thin')
app = Faye::RackAdapter.new(:mount => '/faye', :timeout => 25)
app.add_websocket_extension(PermessageDeflate)

run app