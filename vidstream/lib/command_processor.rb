
# ---------
# Command Processor:
# takes a string command and decides what to do with it.
# ---------

require 'active_support/all'
require 'json'

class CommandProcessor
  
  include Commands # see vidstream/lib/commands.rb for command definitions
  
  # initialized with already-running headless, driver, and vidstream clients
  attr_reader :headless, :driver, :vidstream
  def initialize(headless, driver, vidstream)
    @headless = headless
    @driver = driver
    @vidstream = vidstream
  end

  # The 'launch' command:
  # takes a string, parses commands from it, and runs the command
  def process_original_command(original_command='')
    
    # Split the command at whitespace
    command_parts = original_command.split
    
    # The first word is the 'metacommand', and determines how the rest of the command should be interpreted
    metacommand = command_parts.shift
    return_val = case metacommand
    when "show_lexicon"
      show_lexicon
    when "browser_cmd"
      browser_cmd(command_parts)
    when "add_word"
      add_word(command_parts)
    when "remove_word"
      remove_word(command_parts)
    else
      "invalid metacommand: #{metacommand}. Valid metacommands: #{valid_metacommands_string}"
    end
    return return_val
  end
  
  private
  def valid_metacommands_string
    "browser_cmd <cmd>, add_word <type> <name> <lambda>, remove_word <type> <name>, show_lexicon"
  end
  
end