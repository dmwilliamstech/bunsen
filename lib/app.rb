require 'rubygems'
require 'sinatra'
require 'prawn'
require 'sinatra/contrib'
require 'sinatra/prawn'
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
    def search_any textInput, limit=0
      if String === textInput
        settings.mongo_db['mostRecent'].ensure_index({"$**" => Mongo::TEXT})
        settings.mongo_db.command({:text => 'mostRecent' , :search => "\\" + textInput.split(/[:.-]/).to_s + "\\", limit: limit.to_i })
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
  register Sinatra::Prawn
  register GetOrPost
  set :prawn, { :page_layout => :portrait }
  #Homepage
  get '/' do
    "Use man curl for information on curl'ing. curl -H Accept: application/pdf http://localhost:4567/search?q=params"
  end

  #Displays all Vuls (with optional params for format) 
  get '/vulnerabilities.?:format?' do
    if params[:format].nil?
      settings.mongo_db['mostRecent'].find.to_json
    elsif params[:format] == 'pdf' 
      content_type 'application/pdf'
      pdf = Prawn::Document.new
      #pdf.text settings.mongo_db['mostRecent'].find.to_json 
      #Receiving timeout mongo error only on pdf generation
      pdf.text "Timeout error with Mongo only on this"
      pdf.render()
    elsif params[:format] == 'json' 
      content_type :json
      return settings.mongo_db['mostRecent'].find.to_json
    else
      "Unaccepted format. Please use .json or .pdf"
    end
  end
  
  
  get '/vulnerabilities/' do
    redirect '/vulnerabilities'
  end
  
  # find a document by its ID, converts array to json and displays in web interface
  get '/cve/:id.?:format?' do
    if params[:id]
      if params[:format].nil?
        content_type :json
        document_by_v_id(params[:id]).to_a.to_json
          
      elsif params[:format] == 'pdf' 
        content_type 'application/pdf'
        pdf = Prawn::Document.new
        #pdf.text settings.mongo_db['mostRecent'].find.to_json 
        #Receiving timeout mongo error only on pdf generation
        pdf.text document_by_v_id(params[:id]).to_a.to_json
        pdf.render()
        
      elsif params[:format] == 'json' 
        content_type :json
        return settings.mongo_db['mostRecent'].find.to_json
      else
        "Unaccepted format. Please use .json or .pdf"
      end
      
    else
      "No params entered" #or unaccepted format. Please use .json or .pdf"
    end
  end

  
  #Renders results from search form. Has to be handled seperately, else it wont render form(troubleshooting)
  #Responds to web int or curl with requested format (text/html default)
  get_or_post '/search.?:format?:q?:limit?' do
    if params[:q]
      #Response from the web int
      if params[:format].nil?
        if params[:limit].nil?
          @results = search_any(CGI.unescape(params[:q]))['results'].each
        else
          @results = search_any(CGI.unescape(params[:q]), params[:limit])['results'].each
        end
      elsif params[:format] == 'pdf'
        content_type 'application/pdf'
        @results = search_any(params[:q])['results'].each
        #@return = @results.each unless @results.nil?
        @retPdf = @results.each #"Same Mongo error"
        pdf = Prawn::Document.new
        pdf.text "Example Text" #@retPdf
        pdf.render      
      elsif  params[:format] == 'json'
        content_type :json
        return @results.to_json
      else
        "Unaccepted format. Please use .json or .pdf"
      end
      #response from -Header "application/<whatever content-type>"
      respond_to do |f|
        f.on('text/html'){
          erb :search 
        }
        f.on('application/pdf'){ 
          newPdf = PdfGeneration.new
          pdf = newPdf.create_pdf(@results, params[:q]) 
          return pdf
        }
        f.on('application/json') {
          @results = search_any(params[:q])['results'].each
          return @results.each.to_json

        }
      end
    else
      erb :search
    end
  end
  
  #Renders when any route besides routes listed in this file
  not_found do  
    halt 404, 'page not found'  
  end 
  
  run! if app_file == $0
end
