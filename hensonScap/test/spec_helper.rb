require File.dirname(__FILE__) + '/myapp.rb'

RSpec.configure do |config|

config.before(:each) do
@db = Mongo::Connection.new("localhost", 27017).db("vulnerabilities")
Mongo::DB.stub!(:new).and_return { @db }
end

config.after(:each) do
@db.collections.each do |coll|
coll.drop unless coll.name =~ /^system\./
end
end

end

