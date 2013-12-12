require 'net/http'
require 'nokogiri'
require 'restclient'
link = 'http://localhost:4567/search/results/?q=linux'
page = Nokogiri::HTML(RestClient.get(link))
page.css('div#results table tr th').each do |el|
  puts el
end
