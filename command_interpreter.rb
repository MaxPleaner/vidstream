require 'engtagger'
require 'byebug'
require 'active_support/all'
require 'awesome_print'

class CommandInterpreter
  attr_reader :headless, :driver, :vidstream, :verbs
  def initialize(headless, driver, vidstream, verbs=[])
    @headless = headless
    @driver = driver
    @vidstream = vidstream
    @verbs = verbs
  end
  
  def add_verbs(verbs)
    @verbs = verbs.map(&:to_s)
  end
  
  def process_cmd(cmd)
    words = cmd.downcase.split(" ")
    verb_noun_pairs = get_verb_noun_pairs(words)
  end
  
  class VerbNotFoundError < StandardError
  end
  
  def get_verb_noun_pairs(words)
    results = []
    until words.empty?
      verb_idx = get_next_verb_idx(words)
      raise VerbNotFoundError unless verb_idx
      verb = words[verb_idx]
      words = words[(verb_idx + 1)..-1]
      next_words = nil
      next_verb_idx = get_next_verb_idx(words)
      if next_verb_idx
        next_words = words[next_verb_idx..-1]
        words = words[0..(next_verb_idx - 1)]
      end
      results << construct_verb_noun_pair(verb, words)
      words = next_words || []
    end
    results
  end
    
  def get_next_verb_idx(words)
    words.index { |word| word.in?(@verbs) }
  end
  
  def construct_verb_noun_pair(verb, rest_of_words)
    [verb.to_sym, *rest_of_words]
  end
  

  def demo(cmd)
    url = "http://#{cmd}.com"
    video_path = "public/#{SecureRandom.urlsafe_base64}.mp4"
    vidstream.capture_video(video_path) do
      driver.navigate.to(url)
    end
    return video_path
  end

end

if __FILE__ == $0 # Test it out
  interpreter = CommandInterpreter.new(nil, nil, nil)
  interpreter.add_verbs(["visit", "alert"])
  ap interpreter.process_cmd("visit google and visit facebook")
end
