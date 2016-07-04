# Uncomment this to show logs from DataMapper
# WARNING: uncommenting this will break the selenium server
# DataMapper::Logger.new($stdout, :debug)

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

  before :save do |record|
    defined?(record.class.custom_save_hook) && record.class.custom_save_hook(record)
  end
  before :destroy do |record|
    defined?(record.class.custom_destroy_hook) && record.class.custom_destroy_hook(record)
  end
end

class Verb
  include DataMapper::Resource
  property :id,         Serial
  property :name,       String
  property :action,     Text
  property :created_at, DateTime
  
  before :save do |record|
    defined?(record.class.custom_save_hook) && record.class.custom_save_hook(record)
    true
  end
  before :destroy do |record|
    defined?(record.class.custom_destroy_hook) && record.class.custom_destroy_hook(record)
    true
  end
end

DataMapper.finalize
DataMapper.auto_upgrade!
