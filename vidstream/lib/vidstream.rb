
# Capture video of the firefox browser running in the headless environment

class VidStream
  
  # Initialized with already-running headless and firefox clients
  attr_reader :headless, :driver
  def initialize(headless, driver)
    @headless = headless
    @driver = driver
  end

  # Call a block and record a video of it happening
  # Saves the video file to the specified video_path
  def capture_video(video_path, &blk)
    @headless.video.start_capture
    blk.call
    @headless.video.stop_and_save(video_path)
  end

end
