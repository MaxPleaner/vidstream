# Uncomment this to show logs from DataMapper
DataMapper::Logger.new($stdout, :debug)

# Use SQLite database
DataMapper.setup(:default, 'sqlite:///home/max/Downloads/vidstream/vidstream.sqlite3')

# Pretty standard DataMapper

class Noun
  include DataMapper::Resource
  property :id,         Serial
  property :name,       String
  property :action,     Text
  property :created_at, DateTime
end

class Verb
  include DataMapper::Resource
  property :id,         Serial
  property :name,       String
  property :action,     Text
  property :created_at, DateTime
end

DataMapper.finalize
DataMapper.auto_upgrade!
