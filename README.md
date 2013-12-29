ruby-nist
=========
Current curl instructions
-------------------------
###To search and save as html

	curl -H 'Accept: text/html' http://localhost:9292/search?q=google >> "vul.html"

###Save as pdf or json

	curl -H 'Accept: application/pdf' http://localhost:9292/search?q=google
	curl -H 'Accept: application/json' http://localhost:9292/search?q=google


If search params more than one word use curl -H 'Accept: application/pdf' http://localhost:9292/search -F "q=google chrome"

If there is space between params it is passed to the db as an "AND"

Files will be saved in query.output-format


###Under construction. Check back soon
