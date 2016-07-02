module ExternalCommandRunner
  VidStreamCmd = "ruby vid_stream.rb"
  
  def self.with_process_io(cmd, &blk)
    PTY.spawn(VidStreamCmd) do |output, input|
      blk.call(input, output)
    end
  end
end