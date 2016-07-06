
# Run an external command and then run a block with access to its STDIN and STDOUT

module ExternalCommandRunner

  # The command to start the vidstream process
  VidStreamCmd = "ruby vidstream/start_vidstream.rb"
  
  # Start a command run block with access to its i/o.
  def self.with_process_io(cmd, &blk)
    PTY.spawn(VidStreamCmd) do |output, input|
      blk.call(input, output)
    end
  end
end
