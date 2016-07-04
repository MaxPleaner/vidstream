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
