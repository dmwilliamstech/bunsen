require 'json/ext'
require 'date'
class JsonGeneration
  def create_json arr, params
    separator = '\n'
    out_file = File.open( "#{params}.json", "w") do |f|
      arr.each {|result|
        f.write(result)
        f.write(separator)
      }
    end
  end
end