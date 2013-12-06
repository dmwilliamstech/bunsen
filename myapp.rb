require 'rubygems'
require 'sinatra'
require 'mongo'
require 'json/ext'
require 'active_support/core_ext'


include Mongo
dbName = 'vulnerabilities'
collName = 'mostRecent'
configure do
  connection = MongoClient.new("localhost", 27017)
  set :mongo_connection, connection
  set :mongo_db, connection.db(dbName)
end

get '/' do
  redirect '/search/'
end
get '/collections/?' do
  settings.mongo_db.collection_names
  settings.mongo_db['mostRecent'].find()
end

helpers do
  # a helper method to turn a string ID
  # representation into a BSON::ObjectId
  def ob_id val
    BSON::ObjectId.from_string(val)
  end

  def document_by_id id
    id = ob_id(id) if String === id
    settings.mongo_db['mostRecent'].
      find_one(:id => id).to_json
  end
end
  
  def document_by_v_id id
    if String === id
    settings.mongo_db['mostRecent'].
      find_one(:id => id)
  end
end
  def search_any textInput
    if String === textInput
      settings.mongo_db['mostRecent'].ensure_index({"$**" => Mongo::TEXT})
      settings.mongo_db.command({:text => 'mostRecent' , :search => textInput })
    end
end
  
  def search_by_exact textString
    if String === textString
      settings.mongo_db['mostRecent'].ensure_index({"$**" => Mongo::TEXT})
      settings.mongo_db.command({:text => 'mostRecent',  :search => textString })
     
  end
end


get '/vulnerabilities/?' do
  content_type :json
  settings.mongo_db['mostRecent'].find.to_a.to_json
end

# find a document by its ID
get '/vulnerabilities/:id/?' do
  content_type :json
  document_by_v_id(params[:id]).to_json
  erb :exploreVul

end

get '/search/' do
  erb :search
end
post '/search/results' do
  @results =search_any(params[:q])['results'].each { |result|
    puts 'Search Away'}
 
  erb :search
end
