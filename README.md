ruby-nist
=========
Current curl instructions
All are saved in current working directory
To search and save as html
curl http://localhost:4567/search/results/ -F "q=videolan media" >> "vul.html"

Save as pdf
curl http://localhost:4567/search/results/asPdf -F "q=videolan media"

Save as json
curl http://localhost:4567/search/results/asJson -F "q=videolan media"

If there is space between params it is passed to the db as an "AND"

==================
Under construction
Check back soon
