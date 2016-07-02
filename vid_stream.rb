require 'headless'
require 'selenium-webdriver'
require 'byebug'
require 'securerandom'

require "./headless_gui"
require "./command_interpreter"
require "./command_runner"

at_exit do
  defined?($RunningHeadlessServer) && $RunningHeadlessServer.destroy_without_sync
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
  
  # Run in a headless scope
  headless_gui = HeadlessGUI.new(keep_alive=true) do |headless_gui|
    
    # Initialize VidStream with HeadlessGUI components
    headless = headless_gui.headless
    driver = headless_gui.driver
    vidstream = VidStream.new(headless, driver)

    # Set a global variable which is referenced in the at_exit block
    # to ensure that the headless server stops when the script stops
    $RunningHeadlessServer = headless
    
    # Pass along dependencies to CommandInterpreter and CommandRunner
    cmd_interpreter = CommandInterpreter.new(headless, driver, vidstream)
    cmd_runner = CommandRunner.new(headless, driver, vidstream)
    cmd_interpreter.add_verbs(CommandRunner::KnownCommands.keys)
    
    # Start an I/O loop
    loop do
      input = gets.chomp
      cmd_with_args = cmd_interpreter.process_cmd(input)
      byebug
      output = cmd_runner.run_and_record(cmd=cmd_with_args.shift, args=cmd_with_args)
      puts output
    end
  
  end
  
end
