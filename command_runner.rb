

class CommandRunner

  KnownCommands = {}

  KnownCommands[:visit] = ->(args) {
      page_name = args.shift
      url = "http://#{page_name}.com"
      driver.navigate.to(url)
  }
  
  attr_reader :headless, :driver, :vidstream
  def initialize(headless, driver, vidstream)
    @headless, @driver, @vidstream = headless, driver, vidstream
  end
  
  def run_and_record(cmd, args)
    video_path = "public/#{SecureRandom.urlsafe_base64}.mp4"
    vidstream.capture_video(video_path) do
      result = self.class::KnownCommands[cmd]&.call(args)
    end
    return video_path
  end

end




