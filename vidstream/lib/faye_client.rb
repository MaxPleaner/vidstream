# Vidstream does the subscribing

require 'active_support/all'
require 'bunny'

class FayeClient
  
  def self.create_client
    conn = Bunny.new
    conn.start
    ch = conn.create_channel

    client.subscribe("/save") { |msg| FayeClient.incoming_database_save(msg) }
    client.subscribe('/destroy') { |msg| FayeClient.incoming_database_destroy(msg) }

  end

  def self.start
    ensure_em
    EM.run {
      $client = create_client
    }
  end
  
  # EventMachine needs to be running
  def self.ensure_em
    unless EventMachine.reactor_running? && EventMachine.reactor_thread.alive?
      Thread.new { EventMachine.run }
      sleep 1
    end
  end
  
  def self.incoming_database_save(msg)
    byebug
    record_class, record = msg.record_class, msg.record
    model_class = record_class.capitalize.constantize
    model_class.new(record).save
  end
  
  def self.incoming_database_destroy(msg)
    byebug
    record_class, record = msg.record_class, msg.record
    model_class = record_class.capitalize.constantize
    model_class.find(record.id).destroy
  end
  

end
