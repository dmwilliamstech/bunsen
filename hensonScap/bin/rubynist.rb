require 'json'
require 'net/http'
require 'active_support/core_ext'
require 'mongo'
include Mongo

class NewVuls

  connection = MongoClient.new("localhost")
  db = connection.db("vulnerabilities")
  coll = db["mostRecent"]
  s = Net::HTTP.get_response(URI.parse('https://nvd.nist.gov/static/feeds/xml/cve/nvdcve-2.0-modified.xml')).body
  pg = JSON.pretty_generate(Hash.from_xml(s)["nvd"])
  cursor = coll.find()
  vuls = ActiveSupport::JSON.decode(pg)
  cveList = []
  if not cursor.next_document
    vuls['entry'].each {|entry| 
      coll.insert(entry)
      puts "Values being inserted"
    }
  else
    puts "Else"
    vuls["entry"].each { |entry|
      cve = entry["id"]
      cveList.push(cve)
    }
    vuls["entry"].each { |entry|
      cursor.each { |doc|
        if not cveList.include? "#{doc ['id']}" 
          coll.update({"id" => "#{doc['id']}"}, entry, :upsert=> true )
          puts "New field"
      
      
        elsif cveList.include? "#{doc ['id']}" && "#{doc['last_modified_datetime']}".to_date != entry['last_modified_datetime'].to_date
          coll.update({"id" => "#{doc ['id']}"}, entry, :upset=> false )
          puts "#{doc ['id']} Already exist. Updating..."
      
        else
          puts "Do Nothing"
        end
      
        puts "ID: #{ doc['id'] }
        Published: #{ doc['published_datetime'] }
        Vulnerable_configuration: #{ doc['vulnerable_configuration']}
        Vulnerable_software_list: #{doc['vulnerable_software_list']}
        #{doc['integrity_impact']} 
        Summary: #{doc['summary']}" }
        
      }
      puts cveList
    end
  end
