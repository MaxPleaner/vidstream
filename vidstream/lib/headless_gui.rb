
# Starts the headless process and the selenium browser

class HeadlessGUI
  
  # When creating a headless process, give it an identifier.
  # This makes it possible to re-attach to a headless scope at a later point in time.
  # Although this app doesn't actually make use of this functionality.
  DisplayNumber = 100
  
  # Store references to the headless process and the firefox driver
  attr_reader :headless, :driver

  # This initialize method can be used in two ways:
  # 1. Asynchronously: HeadlessGUI.new(false) { |headless_gui| }
  # 2. Synchronously: headless_gui = HeadlessGUI.new(true)
  def initialize(keep_alive=false, &blk)
    
    # Pass configuration options to the headless environment.
    @headless = Headless.new(
      display: self.class::DisplayNumber,
      reuse_display: true,
      destroy_at_exit: false,
      video: {
        frame_rate: 12,
        codec: 'libx264',
      }
    )
    
    # Start headless process
    @headless.start
    
    # Start firefox browser
    @driver = Selenium::WebDriver.for(:firefox)
    
    # Call a block if one was given
    blk&.call(self)
    
    # Stop the headless process if instructed to do so
    @headless.destroy unless keep_alive
  end
  
end
