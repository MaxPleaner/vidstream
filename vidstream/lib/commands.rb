
# Vidstream's events

module Commands
  
  # Print all the words in the lexicon
  def show_lexicon
    "#{NounLexicon}#{VerbLexicon}".gsub("\n", " ")
  end
  
  # Run a firefox command in headles scope, record it to video, and return the video's filepath
  def browser_cmd(command_parts)
    video_path = "public/#{SecureRandom.urlsafe_base64}.mp4"
    vidstream.capture_video(video_path) do
      parsed_commands = SentenceInterpreter.interpret(command_parts.join(" ").gsub("\n", " "))
      parsed_commands.each do |command|
        verb = command[:verb].to_sym
        nouns = command[:nouns]
        Lexicon[:verbs][verb]&.call(*nouns) rescue $driver.raise_error("Error. Verb: #{verb}, nouns: #{nouns}", nil)
      end
    end
    video_path
  end
  
  # Add a word to the lexicon
  # Triggers the in-memory lexicon to reload its state from the database.
  def add_word(command_parts)
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
  end
  
  # Remove a word from the lexicon
  # Triggers the in-memory lexicon to reload its state from the database.
  def remove_word(command_parts)
    type = command_parts.shift
    name = command_parts.shift
    record_class = type.capitalize.constantize
    sleep 1; # wait until server creates record
    matching_record = record_class.first(name: name)
    matching_record&.destroy
    Lexicon.reload
    Lexicon.copy_self_to(verbs: VerbLexicon, nouns: NounLexicon)
    "#{matching_record&.attributes} ".gsub("\n", " ")
  end
end