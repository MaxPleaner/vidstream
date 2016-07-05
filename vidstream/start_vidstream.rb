# Gem dependencies
require 'headless'               # A virtual X display
require 'selenium-webdriver'     # A virtual Firefox browser
require 'byebug'                 # A debugger
require 'securerandom'           # A random string generator
require 'sentence_interpreter'   # A sentence parsing gem I made
require 'data_mapper'            # An ORM
require 'eventmachine'           # An event loop, used for Faye pub-sub
require 'faye'

# Local file dependencies
(require_relative "./lib/monkeypatches.rb").then_require_from_lib([
  './headless_gui.rb',      # Virtual X display and Firefox browser
  './vidstream.rb',         # Captures video
  './command_processor.rb', # Interprets commands,
  './faye_client.rb',       # Syncs DataMapper when database changes
  (require_relative './lib/database.rb').then_require_from_lib([
    './lexicon.rb',         # Map verbs and nouns to procs
    './seeds.rb'            # Some sample data
  ]),
])

# Expose Lexicon to sentence_interpreter's VerbLexicon and NounLexicon classes
# This sets up the initial state of the interpreter to mirror the database.
Lexicon.copy_self_to(verbs: VerbLexicon, nouns: NounLexicon)

# Add hooks to lexicon so that sentence_analyser is updated when the database changes
def word_removed(word_type, record)
  find_lexicon(word_type).delete(record.name&.to_sym)
  true
end
def word_created(word_type, record)
  find_lexicon(word_type)[record.name&.to_sym] &&= (eval(record.action))
  true
end
def find_lexicon(word_type)
  word_type.to_s.eql?("verb") ? VerbLexicon : NounLexicon
end
Lexicon[:on_destroy_hook] = ->(*args) { word_removed(*args) }
Lexicon[:on_create_or_update_hook] = ->(*args) {  word_created(*args) }

# Make sure the headless server stops when the script stops
at_exit do
  defined?(RunningHeadlessServer) && RunningHeadlessServer.destroy_without_sync
end

# Start faye listener in a thread (helps synchronize DataMapper between multiple databases)
FayeClient.start

# Start selenium-webdriver and run block in headless scope
headless_gui = HeadlessGUI.new(keep_alive=true) do |headless_gui|

  # Define the main components as globals so they don't always need to be passed as arguments
  $headless = RunningHeadlessServer = headless_gui.headless
  $driver = driver = headless_gui.driver
  $vidstream = VidStream.new($headless, $driver)
  $command_processor = CommandProcessor.new($headless, $driver, $vidstream)

  # Error handler: show errors as Javascript alerts in the selenium browser
  $driver.define_singleton_method(:raise_error) do |text, error_obj|
    byebug
    puts "\n\n**************\n\nERROR : #{text} : #{error_obj}\n\n**************\n\n"
    $driver.execute_script("alert(arguments[0])", text)
  end
  
  # Run this block if this file is executed directly (not required)
  if __FILE__ == $0
    # Interpret commands and run them on the headless GUI
    loop do
      # input is a single line containing a string command (something like "visit google")
      # output is a local path to a video file
      puts $command_processor.process_original_command(gets.chomp)
    end
  end
  
end
