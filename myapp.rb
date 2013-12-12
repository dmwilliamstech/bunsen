require 'rubygems'
require 'sinatra'
require 'mongo'
require 'json/ext'
require 'active_support/core_ext'
require "sinatra/base"
require 'prawn'
require 'date'

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
  def create_pdf arr
    if arr
  pdf = Prawn::Document.generate "vul.pdf", :page_layout => :landscape do |pdf|
      pdf.text "Henson Scap", :size => 18
  pdf.font "Helvetica"
  pdf.text "Details of Vulnerabilties as of #{Date.today.to_s}", :style => :bold_italic
  pdf.stroke_horizontal_rule
  pdf.text "See next page", :size => 10
  pdf.move_down 10
  items = [["# Of Vuls","CVE-ID", "Summary", "Vulnerable Software"]]
  items += arr['results'].each_with_index.map do |result, i|
    if result['obj']['vulnerable_software_list']
      vsl = result['obj']['vulnerable_software_list']['product']
    else
      vsl = "No software given"
    end#end if

 
    [
      i + 1,
      result['obj']['id'],
      result['obj']['summary'],
      vsl.to_s,
    ]

  end #end each_with_index loop


  pdf.table items, :header => true,
    :column_widths => { 0 => 50, 1 => 50, 3 => 350}, :row_colors => ["d2e3ed", "FFFFFF"] do
      style(columns(3)) {|x| x.align = :right }
  end#ends table
  end#end pdf creation
  end #end if arr
end #end method

def create_json arr
  separator = '\n'
  out_file = File.open("vul.json", "w") do |f|
    arr.each {|result|
    f.write(result)
    f.write(separator)
  }
  end
end
def create_html arr
  separator = '\n'
  out_file = File.open("vul.html", "w") do |f|
    arr.each {|result|
    f.write(result)
    f.write(separator)
  }
  end
end
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
get_or_post '/search/results/asJson' do
  @results =search_any(params[:q])['results']
  create_json(@results)
  puts @results
end
get_or_post '/search/results/asPdf' do
  @results =search_any(params[:q])
 
  create_pdf(@results)
  puts "pdf created"
end



