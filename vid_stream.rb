require 'headless'
require 'selenium-webdriver'
require 'sinatra'

class VidStream
  
  def capture_video(video_path, &blk)
    `rm #{video_path}` rescue nil
    @headless.video.start_capture
    blk.call
    @headless.video.stop_and_save(video_path)
  end

  def headless(keep_alive=false, &content_blk)
    @headless = Headless.new(
      video: {
        frame_rate: 12,
        codec: 'libx264'
      }
    )
    @headless.start
    content_blk.call
    @headless.destroy unless keep_alive
  end

  def driver
    @driver ||= Selenium::WebDriver.for(:firefox)
  end

end

def init
  video_path = ARGV.shift || "test.mp4"
  vid_stream = VidStream.new
  vid_stream.headless(keep_alive=true) do
    get '/' do
      erb :root
    end
  end
end

if __FILE__ == $0
  init
end
