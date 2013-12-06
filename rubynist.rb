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
pg = JSON.pretty_generate(Hash.from_xml(s)["nvd"])
cursor = coll.find()
vuls = ActiveSupport::JSON.decode(pg)
if not cursor.next_document
  vuls['entry'].each {|entry| 
  coll.insert(entry)
  puts "Values being inserted"
}
else
  puts "Else"
  vuls["entry"].each { |entry|
  cve = entry["id"]
  cursor.each { |doc|
    if cve != "#{doc ['id']}" 
      coll.update({"id" => "#{doc['id']}"}, entry, :upsert=> true )
      puts "New field"
      next
      
    elsif cve == "#{doc ['id']}" && "#{doc['last_modified_datetime']}".to_date != entry['last_modified_datetime'].to_date
      coll.update({"id" => "#{doc ['id']}"}, entry)
      puts "Already existing"
      next
    else
      puts "Do Nothing"
      next
    end
      
  puts "ID: #{ doc['id'] }
        Published: #{ doc['published_datetime'] }
        Vulnerable_configuration: #{ doc['vulnerable_configuration']}
        Vulnerable_software_list: #{doc['vulnerable_software_list']}
        #{doc['integrity_impact']} 
        Summary: #{doc['summary']}" }
        next

}
end