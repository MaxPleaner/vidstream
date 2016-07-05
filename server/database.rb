# Uncomment this to show logs from DataMapper
DataMapper::Logger.new($stdout, :debug)

# Use SQLite database
DataMapper.setup(:default, 'sqlite:///home/max/Downloads/vidstream/vidstream.sqlite3')

# The "Noun" and "Verb" tables have "id", "name", "action", and "created_at" columns
# To add hooks, define "custom_save_hook" or "custom_destroy_hook" singleton methods

class Noun
  include DataMapper::Resource
  
  property :id,         Serial
  property :name,       String
  property :action,     Text
  property :created_at, DateTime

  after :save do |record|
    FayeClient.publish_save(record)
    true
  end
  after :destroy do |record|
    FayeClient.publish_destroy(record)
    true
  end
end

class Verb
  include DataMapper::Resource
  property :id,         Serial
  property :name,       String
  property :action,     Text
  property :created_at, DateTime
  
  after :save do |record|
    FayeClient.publish_save(record)
    true
  end
  after :destroy do |record|
    FayeClient.publish_destroy(record)
    true
  end
end

DataMapper.finalize
DataMapper.auto_upgrade!
