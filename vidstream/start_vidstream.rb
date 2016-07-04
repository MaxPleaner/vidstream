# Gem dependencies
require 'headless'
require 'selenium-webdriver'
require 'byebug'
require 'securerandom'
require 'sentence_interpreter'
require 'data_mapper'

# Local file dependencies
(require_relative "./lib/monkeypatches.rb").then_require_from_lib([
  './vidstream.rb',
  './headless_gui.rb',
  './command_processor.rb',
  (require_relative './lib/database.rb').then_require_from_lib([
    './lexicon.rb',
    './seeds.rb'
  ]),
])

# Add custom lexicon, used by sentence_analyser
Lexicon.copy_self_to(verbs: VerbLexicon, nouns: NounLexicon)

# Add hooks to lexicon so that sentence_analyser is updated when the database changes
def find_lexicon(word_type)
  word_type.to_s.eql?("verb") ? VerbLexicon : NounLexicon
end
def word_removed(word_type, record)
  find_lexicon(word_type).delete(record.name&.to_sym)
end
def word_created_or_updated(word_type, record)
  find_lexicon(word_type)[record.name&.to_sym] &&= (eval(record.action))
end
Lexicon[:on_destroy_hook] = ->(*args) { word_removed(*args) }
Lexicon[:on_create_or_update_hook] = ->(*args) {  word_created_or_updated(*args) }

# Make sure the headless server stops when the script stops
at_exit do
  defined?(RunningHeadlessServer) && RunningHeadlessServer.destroy_without_sync
end

# Run this block if this file is executed directly (not required)
if __FILE__ == $0

  # Start selenium-webdriver and run block in headless scope
  headless_gui = HeadlessGUI.new(keep_alive=true) do |headless_gui|

    # Define the main components as globals so they don't always need to be passed as arguments
    $headless = RunningHeadlessServer = headless_gui.headless
    $driver = driver = headless_gui.driver
    $vidstream = VidStream.new($headless, $driver)
    $command_processor = CommandProcessor.new($headless, $driver, $vidstream)

    # Error handler: show errors as Javascript alerts in the selenium browser
    $driver.define_singleton_method(:raise_error) do |text, error_obj|
      puts "\n\n**************\n\nERROR : #{text} : #{error_obj}\n\n**************\n\n"
      $driver.execute_script("alert(arguments[0])", text)
    end
    
    # Start an I/O loop
    loop do
      puts $command_processor.process_original_command(gets.chomp)
    end
    
  end
end
