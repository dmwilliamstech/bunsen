bunsen
=========
A simple web-API for accessing the NIST NVD.


Installation instructions
-------------------------
###Pre-reqs(will be added to install.sh)

Ruby >2.0 (rvm install preferred) http://rvm.io/

RubyGems(installed with rvm)

	gem install bundler

##bunsen Installation
	git clone https://github.com/airgap/bunsen.git

run installMongo.sh (to install mongo) 

Mongo must be installed to run the app!!!!

Ensure text Searching is enabled. (/etc/mongod.conf setParameter = textSearchEnabled=true)

bundle (to install gems)

start mongo(if not already started)

cd to bunsen directory and "rackup"!


Current curl instructions
-------------------------
###To search and save as html

	curl -H 'Accept: text/html' http://localhost:9292/search?q=google >> "vul.html"

###Save as pdf or json

	curl -H 'Accept: application/pdf' http://localhost:9292/search?q=google
	curl -H 'Accept: application/json' http://localhost:9292/search?q=google


If search params are more than one word use curl -H 'Accept: application/pdf' http://localhost:9292/search -F "q=google chrome"

If there is space between search params it is as an "AND"

License
-

Apache License, Version 2.0

http://www.apache.org/licenses/LICENSE-2.0.html
