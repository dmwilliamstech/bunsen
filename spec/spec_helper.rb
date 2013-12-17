require 'net/http'
require 'mongo'
require 'active_support/core_ext'
require 'nokogiri'
require 'restclient'
require 'test/unit'
require 'rack/test'
require 'rspec'
require 'json'

require File.expand_path '../../lib/app.rb', __FILE__

module RSpecMixin
  include Rack::Test::Methods
  def app 
    NistApp 
  end
end

RSpec.configure do |config|

  config.include RSpecMixin
  
  config.before(:each) do
    @db = Mongo::Connection.new("localhost", 27017).db("vulnerabilities")
    Mongo::DB.stub(:new).and_return { @db }
  end

  config.after(:each) do
    @db.collections.each do |coll|
      coll.drop unless coll.name =~ /^system\./
    end
  end

end

