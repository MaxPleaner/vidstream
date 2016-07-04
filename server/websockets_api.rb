class WebsocketsAPI

  attr_reader :vidstream_in, :vidstream_out
  def initialize(vidstream_io)
    @vidstream_in, @vidstream_out = vidstream_io
  end

  def on_open(ws, settings)
    settings.sockets << ws
  end

  def on_close(ws, settings)
    settings.sockets.delete(ws)
  end

  def on_message(ws, settings, msg)
    vidstream_in.write(msg + "\n")
    scrapped_line = vidstream_out.gets # scrap a line
    vid_url = vidstream_out.gets || ""
    vid_url = vid_url.split("public/")[-1].
                      split("\r\n")[0]
    EM.next_tick { settings.sockets.each{|s| s.send(vid_url) } }
  end

end