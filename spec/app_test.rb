require File.expand_path '../spec_helper.rb', __FILE__

## include Mongo

# class MyAppTest < Test::Unit::TestCase
#   include Rack::Test::Methods
# 
#   def app
#     Sinatra::Application
#   end
# 
#   
#   def test_my_default_redirect
#     get 'http://localhost:4567'
#     follow_redirect!
#     assert_equal 'http://localhost:4567/search/', last_request.url
#     assert last_response.ok?
#   end
#   def test_my_params
#     get 'http://localhost:4567/vulnerabilities/'
#     assert last_response.ok?
#   end
#   
#   def test_my_default
#     get 'http://localhost:4567/search/'
#     assert last_response.ok?
#   end
# 
# 
# end

describe "My Sinatra Application" do
  
  it "should respond to GET /" do
    get '/'
    last_response.status.should == 302
  end
    
  describe "#find_document_by_v_id" do
    it "find doc by id" do
      connection = MongoClient.new("localhost")
      db = connection.db("vulnerabilities")
      coll = db["mostRecent"]
      coll.find_one(:id => "CVE-2013-7009").to_json.should == Net::HTTP.get_response(URI.parse('http://localhost:4567/vulnerabilities/CVE-2013-7009')).body
      
    end
  end
  describe "#search_any" do
    it "will should search all db fields and display results that contain(all) parameters/keywords" do
      #I am entering the word "unspecificed" and a specific datetime(should return a single result)
      textInput = "unspecified 2013-12-07T16:55:09.623-05:00"
      connection = MongoClient.new("localhost")
      db = connection.db("vulnerabilities")
      coll = db["mostRecent"]
      coll.ensure_index({"$**" => Mongo::TEXT})
      db.command({:text => 'mostRecent' , :search => "\\" + textInput.split(' ').to_s + "\\"}).count().should >= 1
    end
  end
  # describe "return all db docs" do
  #   connection = MongoClient.new("localhost")
  #   db = connection.db("vulnerabilities")
  #   coll = db["mostRecent"]
  #   coll.find().to_json.should == Net::HTTP.get_response(URI.parse('http://localhost:4567/vulnerabilities/')).body
  # end
  # describe "when no params" do
  # 
  #   it "pdf generation" do
  #     request = Net::HTTP.get_response(URI.parse('http://localhost:4567/search/results/pdf'))
  #     request.code.should == "302"
  #   end
  #   it "json generation" do
  #     request = Net::HTTP.get_response(URI.parse('http://localhost:4567/search/results/asJson'))
  #     request.code.should == "302"
  #   end
  # end
  # #This test fails
  # describe "no docs found" do 
  #   it "no results in db" do
  #     textInput = "jjddjdj"
  #     connection = MongoClient.new("localhost")
  #     db = connection.db("vulnerabilities")
  #     coll = db["mostRecent"]
  #     coll.ensure_index({"$**" => Mongo::TEXT})
  #     db.command({:text => 'mostRecent' , :search => "\\" + textInput.split(' ').to_s + "\\"}).count().should == 0
  #   end
  #   it "not results from search url" do
  #     link = 'http://localhost:4567/search/results/?q=peekaboo'
  #     page = Nokogiri::HTML(RestClient.get(link))
  #     page.css('div#results table tr th').each do |el|
  #       if not el.text
  #         el.text.should == 0
  #       else
  #         el.text != 0
  #       end
  #     end
  #   
  #   end
  # end
end