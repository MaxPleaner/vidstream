require './start_server.rb'

noun = Noun.create(
  name: "test",
  action: "->() {'test'}"
)

byebug

true