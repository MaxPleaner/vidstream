require 'active_support/all'
require 'json'

class CommandProcessor
  
  attr_reader :headless, :driver, :vidstream
  def initialize(headless, driver, vidstream)
    @headless = headless
    @driver = driver
    @vidstream = vidstream
  end

  def process_original_command(original_command='')
    # byebug
    parse_and_call_commands(original_command)
  end

  def parse_and_call_commands(original_command)
    command_parts = original_command.split(" ")
    metacommand = command_parts.shift
    return_val = case metacommand
    when "show_lexicon"
      "#{NounLexicon}#{VerbLexicon}".gsub("\n", " ")
    when "browser_cmd"
      video_path = "public/#{SecureRandom.urlsafe_base64}.mp4"
      vidstream.capture_video(video_path) do
        parsed_commands = SentenceInterpreter.interpret(command_parts.join(" "))
        parsed_commands.each do |command|
          verb = command[:verb].to_sym
          nouns = command[:nouns]
          Lexicon[:verbs][verb]&.call(*nouns) rescue $driver.raise_error("Error. Verb: #{verb}, nouns: #{nouns}", nil)
        end
      end
      video_path
    when "add_word"
      type = command_parts.shift
      name = command_parts.shift
      action = command_parts.shift
      attrs = { name: name, action: action }
      record_class = type.capitalize.constantize
      sleep 1 # # wait until server creates record
      matching_record = record_class.first(name: name)
      new_word = matching_record&.update(attrs) || record_class.create(attrs)
      Lexicon.reload
      Lexicon.copy_self_to(verbs: VerbLexicon, nouns: NounLexicon)
      "#{new_word.attributes}".gsub("\n", " ")
    when "remove_word"
      type = command_parts.shift
      name = command_parts.shift
      record_class = type.capitalize.constantize
      sleep 1; # wait until server creates record
      matching_record = record_class.first(name: name)
      matching_record&.destroy
      Lexicon.reload
      Lexicon.copy_self_to(verbs: VerbLexicon, nouns: NounLexicon)
      "#{matching_record&.attributes} ".gsub("\n", " ")
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