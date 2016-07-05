# Vidstream does the subscribing

# require 'active_support/all'
# require 'bunny'

class FayeClient
  
  def self.start
  end
  
  def self.incoming_database_save(msg)
    # byebug
    # record_class, record = msg.record_class, msg.record
    # model_class = record_class.capitalize.constantize
    # model_class.new(record).save
  end
  
  def self.incoming_database_destroy(msg)
    # byebug
    # record_class, record = msg.record_class, msg.record
    # model_class = record_class.capitalize.constantize
    # model_class.find(record.id).destroy
  end

end
