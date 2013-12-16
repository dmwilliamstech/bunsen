require 'rubygems'
require 'sinatra'
require 'mongo'
require 'active_support/core_ext'
require "sinatra/base"
require './output'

include Mongo

dbName = 'vulnerabilities'
collName = 'mostRecent'
timeNow = Time.new
configure do
  connection = MongoClient.new("localhost", 27017)
  set :mongo_connection, connection
  set :mongo_db, connection.db(dbName)
end


helpers do
  # a helper method to turn a string ID
  # representation into a BSON::ObjectId
  
  def ob_id val
    BSON::ObjectId.from_string(val)
  end#end ob_id

  def document_by_v_id id
    if String === id
    settings.mongo_db['mostRecent'].
      find_one(:id => id)
  end#end if
end#end document_by_v_id

  def search_any textInput
    if String === textInput
      settings.mongo_db['mostRecent'].ensure_index({"$**" => Mongo::TEXT})
      settings.mongo_db.command({:text => 'mostRecent' , :search => "\\" + textInput.split(' ').to_s + "\\"})
    else
      redirect back
    end
end

 module GetOrPost
  def get_or_post(path, options = {}, &block)
  get(path, options, &block)
  post(path, options, &block)
  end
end
end
register GetOrPost


get '/' do
  redirect '/search/'
end
get '/collections/?' do
  settings.mongo_db.collection_names
  settings.mongo_db['mostRecent'].find()
end
get '/vulnerabilities/?' do
  content_type :json
  settings.mongo_db['mostRecent'].find.to_a.to_json
end

# find a document by its ID
get '/vulnerabilities/:id/?' do
  content_type :json
  document_by_v_id(params[:id]).to_json

end

get '/search/' do
  erb :search
end
get_or_post '/search/results/' do
  @results =search_any(params[:q])['results'].each { |result|
    puts 'Search Away'}
  erb :search
end

get_or_post '/search/results/:outPut' do
  @results =search_any(params[:q])
  newOut = OutPut.new
  desOut = newOut.out_put_format(params[:outPut].downcase, @results, params[:q])

end



