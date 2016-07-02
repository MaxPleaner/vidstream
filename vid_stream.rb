require 'headless'
require 'selenium-webdriver'
require 'byebug'
require 'securerandom'

at_exit do
  defined?(RunningHeadlessServer) && RunningHeadlessServer.destroy_without_sync
end

class HeadlessGUI
  DisplayNumber = 100 # can be any number, facilitates re-attaching from Sinatra scope
  attr_reader :headless, :driver
  def initialize(keep_alive=false, &blk)
    @headless = Headless.new(
      display: self.class::DisplayNumber,
      reuse_display: true,
      destroy_at_exit: false,
      video: {
        frame_rate: 12,
        codec: 'libx264',
      }
    )
    @headless.start
    @driver = Selenium::WebDriver.for(:firefox)
    blk&.call(self)
    @headless.destroy unless keep_alive
  end
end

class VidStream
  
  attr_reader :headless, :driver
  def initialize(headless, driver)
    @headless = headless
    @driver = driver
  end

  def capture_video(video_path, &blk)
    @headless.video.start_capture
    blk.call
    @headless.video.stop_and_save(video_path)
  end

end


if __FILE__ == $0
  headless_gui = HeadlessGUI.new(keep_alive=true) do |headless_gui|
    $headless = RunningHeadlessServer = headless_gui.headless
    $driver = driver = headless_gui.driver
    $vidstream = VidStream.new($headless, $driver)
    loop do
      url = "http://#{gets.chomp}.com"
      video_path = "public/#{SecureRandom.urlsafe_base64}.mp4"
      $vidstream.capture_video(video_path) do
        $driver.navigate.to(url)
      end
      puts video_path
    end
  end
end
