require 'headless'
require 'selenium-webdriver'
require 'byebug'

class VidStream
  
  def capture_video(video_path, &blk)
    @headless.video.start_capture
    blk.call
    @headless.video.stop_and_save(video_path)
  end

  def headless(keep_alive=false, &content_blk)
    @headless = Headless.new
    @headless.start
    content_blk.call
    @headless.destroy unless keep_alive
  end

  def driver
    @driver ||= Selenium::WebDriver.for(:firefox)
  end

end

def init
  video_path = ARGV.shift || "test.mov"
  vid_stream = VidStream.new
  vid_stream.headless(keep_alive=true) do
    vid_stream.capture_video(video_path) do
      vid_stream.driver.navigate.to("http://google.com")
      puts vid_stream.driver.title
    end
    vid_stream.capture_video("test2.mov") do
      vid_stream.driver.navigate.to("gmail.com")
      puts vid_stream.driver.title
    end
  end
end

if __FILE__ == $0
  init
end
