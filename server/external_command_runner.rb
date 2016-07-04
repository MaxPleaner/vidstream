module ExternalCommandRunner
  VidStreamCmd = "ruby vidstream/start_vidstream.rb"
  
  def self.with_process_io(cmd, &blk)
    PTY.spawn(VidStreamCmd) do |output, input|
      blk.call(input, output)
    end
  end
end
