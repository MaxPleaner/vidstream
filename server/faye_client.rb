# Sinatra Server does the publishing

require 'bunny'

class FayeClient
  
  def self.create_client
    conn = Bunny.new
    conn.start
  end
  
  def self.start
    SinatraServer.ensure_em
    EM.run {
      $faye_client = FayeClient.create_client
    }
  end

  # These are called from the database hooks
  def self.publish_save(record)
    $faye_client.publish("/save", published_record_object(record) )
  end

  def self.publish_destroy(record)
    $faye_client.publish("/destroy", published_record_object(record) )
  end

  private
  def self.published_record_object(record)
     {
       record_class: record.class.to_s,
       record: record.attributes
     }
  end

end