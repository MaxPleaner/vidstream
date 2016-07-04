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
