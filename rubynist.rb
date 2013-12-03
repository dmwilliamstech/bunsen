require 'json'
require 'net/http'
require 'active_support/core_ext'
require 'mongo'
require 'date'

include Mongo

connection = MongoClient.new("localhost")
db = connection.db("vulnerabilities")
coll = db["mostRecent"]
s = Net::HTTP.get_response(URI.parse('http://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-recent.xml')).body
doc = JSON.pretty_generate(Hash.from_xml(s)["nvd"])
cursor = coll.find()
ActiveSupport::JSON.decode(doc)["entry"].each do |entry|
  cve = entry["id"]
  cursor.each { |doc|
    if cve != "#{doc ['id']}" 
      coll.update({"id" => "#{doc['id']}"}, entry, :upsert=> true )
      
    elsif cve == "#{doc ['id']}" && "#{doc['last_modified_datetime']}".to_date != entry['last_modified_datetime'].to_date
      coll.update({"id" => "#{doc ['id']}"}, entry)
    else
      next
    end
      
  puts "ID: #{ doc['id'] }
        Published: #{ doc['published_datetime'] }
        Vulnerable_configuration: #{ doc['vulnerable_configuration']}
        Vulnerable_software_list: #{doc['vulnerable_software_list']}
        #{doc['integrity_impact']} 
        Summary: #{doc['summary']}" }
end
