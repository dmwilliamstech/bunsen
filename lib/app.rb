require 'rubygems'
require 'sinatra'
require 'sinatra/contrib'
require 'mongo'
require 'json/ext'
require 'active_support'
require 'active_support/core_ext'
require "sinatra/base"
require_relative './pdfgeneration'


include Mongo

class NistApp < Sinatra::Base
  
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

    #This method searches MongoDB for document with the :id that matches input
    def document_by_v_id id
      if String === id
        settings.mongo_db['mostRecent'].
        find_one(:id => id)
      end#end if
    end#end document_by_v_id

    #This method searches MongoDB for the search params(seperated by ':', '.', '-' , ' ')
    def search_any textInput
      if String === textInput
        settings.mongo_db['mostRecent'].ensure_index({"$**" => Mongo::TEXT})
        settings.mongo_db.command({:text => 'mostRecent' , :search => "\\" + textInput.split(/[:.-]/).to_s + "\\"})
        #else
        #redirect back
      end
    end
    
    #This module simplifies the get or post handler
    module GetOrPost
      def get_or_post(path, options = {}, &block)
        get(path, options, &block)
        post(path, options, &block)
      end
    end
  end
  
  register Sinatra::RespondWith
  register GetOrPost

  #Homepage
  get '/' do
    "Use man curl for information on curl'ing. curl -H Accept: application/pdf http://localhost:4567/search/?q=params"
  end

  #Displays all Vuls (with optional params for format) 
  get '/vulnerabilities.?:format?/' do
    content_type :json
    JSON.pretty_generate(settings.mongo_db['mostRecent'].find)
  end

  # find a document by its ID, converts array to json and displays in web interface
  get '/vulnerabilities/:id?.?:format?' do
    content_type :json
    JSON.pretty_generate(document_by_v_id(params[:id]).to_a)
  end

  # Renders search form
  get '/search/' do
    erb :search
  end
  
  #Renders results from search form. Has to be handled seperately, else it wont render form(troubleshooting)
  #Responds to web int or curl with requested format (text/html default)
  get_or_post '/search.?:format?/:q?' do
    @results =search_any(params[:q])['results'].each
    respond_to do |f|
      f.on('text/html'){
        erb :search 
      }
      f.on('application/pdf') { 
        newPdf = PdfGeneration.new
        pdf = newPdf.create_pdf(@results, params[:q]) 
        return pdf
      }
      f.on('application/json') {
        return JSON.pretty_generate(@results.each)
      }
    end
  end
  
  #Renders when any route besides routes listed in this file
  not_found do  
    halt 404, 'page not found'  
  end 
  
  run! if app_file == $0
end
