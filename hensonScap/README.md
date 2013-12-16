ruby-nist
=========
Current curl instructions
To search and save as html
curl http://localhost:4567/search/results/ -F "q=videolan media" >> "vul.html"

Save as pdf or json
curl http://localhost:4567/search/results/<format> -F "q=videolan media"
<format> = pdf or json (i.e. curl http://localhost:4567/search/results/pdf -F "q=videolan media")

If there is space between params it is passed to the db as an "AND"
Files will be saved in <query>.<output format>
	videolan media.pdf or videolan media.json in the hensonScap/lib (for now)
==================
Under construction
Check back soon
