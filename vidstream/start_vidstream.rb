# Gem dependencies
require 'headless'               # A virtual X display
require 'selenium-webdriver'     # A virtual Firefox browser
require 'byebug'                 # A debugger
require 'securerandom'           # A random string generator
require 'sentence_interpreter'   # A sentence parsing gem I made
require 'data_mapper'            # An ORM
require 'eventmachine'           # An event loop, used for Faye pub-sub

# Local file dependencies
(require_relative "./lib/monkeypatches.rb").then_require_from_lib([
  './headless_gui.rb',       # Virtual X display and Firefox browser
  './vidstream.rb',          # Captures video
  (require_relative './lib/commands.rb').then_require_from_lib([
    './command_processor.rb' # Parses and executes incoming nouns
  ]),
  (require_relative './lib/database.rb').then_require_from_lib([
    './lexicon.rb',         # Map verbs and nouns to procs
    './seeds.rb'            # Some sample data
  ]),
])

# Make sure the headless server stops when the script stops
at_exit do
  defined?(RunningHeadlessServer) && RunningHeadlessServer.destroy_without_sync
end

# Start selenium-webdriver and run block in headless scope
headless_gui = HeadlessGUI.new(keep_alive=true) do |headless_gui|

  # Define the main components as globals so they don't always need to be passed as arguments
  $headless = RunningHeadlessServer = headless_gui.headless
  $driver = headless_gui.driver
  $vidstream = VidStream.new($headless, $driver)
  $command_processor = CommandProcessor.new($headless, $driver, $vidstream)

  # Custom errors can be raised Javascript alerts in the virtual browser.
  # These are visible when the video of the virtual browser is played
  # Usage example (when called from a verb's 'action' proc):
  # $driver.raise_error("There was an error.", other_data=nil)
  $driver.define_singleton_method(:raise_error) do |text, error_obj|
    $driver.execute_script("alert('there was an error')")
  end
  
  # Get the initial state from the database
  Lexicon.reload
  
  # Expose Lexicon to sentence_interpreter's VerbLexicon and NounLexicon classes
  # This sets up the initial state of the interpreter to mirror the database.
  Lexicon.copy_self_to(verbs: VerbLexicon, nouns: NounLexicon)
  
  # Run this block if this file is executed directly (not required)
  if __FILE__ == $0
    
    # Interpret commands and run them on the headless GUI
    loop do
      
      # The first word of any input is considered the "meta command".
      # This determines how the rest of the input's words are parsed and what the output it.
      # See vidstream/lib/command_processor.rb for more details.
      puts $command_processor.process_original_command(gets.chomp)
      
    end
  end
  
end
