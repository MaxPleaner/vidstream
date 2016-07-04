class CommandProcessor
  
  attr_reader :headless, :driver, :vidstream
  def initialize(headless, driver, vidstream)
    @headless = headless
    @driver = driver
    @vidstream = vidstream
  end

  def process_original_command(original_command='')
    video_path = "public/#{SecureRandom.urlsafe_base64}.mp4"
    vidstream.capture_video(video_path) do
      parse_and_call_commands(original_command)
    end
    return video_path
  end

  def parse_and_call_commands(original_command)
    parsed_commands = SentenceInterpreter.interpret(original_command)
    parsed_commands.each do |command|
      verb = command[:verb].to_sym
      nouns = command[:nouns]
      Lexicon[:verbs][verb]&.call(*nouns) rescue $driver.raise_error("Error. Verb: #{verb}, nouns: #{nouns}")
    end
  end
  
end