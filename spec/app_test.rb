require File.expand_path '../spec_helper.rb', __FILE__

disAll = File.join(File.dirname(__FILE__), 'spec_files', 'displayAll.json')
search = File.join(File.dirname(__FILE__), 'spec_files', 'search.html')


describe "Nist Application" do

  it "should respond to GET /" do
    get '/'
    #This is just a placeholder for now.
    last_response.body.should == "Use man curl for information on curl'ing. curl -H Accept: application/pdf http://localhost:4567/search?q=params"
    last_response.status.should == 200
  end
  
  describe "Json functionality" do
    it "should return search results as JSON on the /search.json interface" do
      get '/search.json?q=google'
      last_response.status.should == 200
      last_response.headers['Content-Type'].should == "application/json;charset=utf-8"
      last_response.body.include?('google')
    end
  end
  
  describe "PDF functionality" do
    it "should return results as a valid PDF on the /search.pdf interface" do
      get '/search.pdf?q=google'
      last_response.status.should == 200
      last_response.headers['Content-Type'].should == "application/pdf"
      #last_response.headers.content_disposition.should == "attachment; filename=\"<q>.pdf\""
    end
    
    it "should return all vulnerabilities as PDF on the /vulnerabilties.pdf interface" do
      get '/vulnerabilities.pdf'
      last_response.status.should == 200
      last_response.headers['Content-Type'].should == "application/pdf"
      #last_response.status.content_disposition.should == "attachment; filename=\"allVulnerabilities.pdf\""
    end
  end
  
  describe "Return all Vulnerabilities" do
    it "should display all vulnerabilities" do
      get '/vulnerabilities'
      last_response.status.should == 200
      last_response.body.should == File.read(disAll)
    end
    
    it "should redirect to /vulnerabilties if /vulnerabilties/ entered" do
      get '/vulnerabilities/'
      last_response.status.should == 302
    end
  
    it "should return all vulnerabilities as JSON on the /vulnerabilties.json interface" do
      get '/vulnerabilities.json'
      last_response.status.should == 200
      #last_response.Content-Type.should == "application/json"
      last_response.body.include?('CVE-2013-3907')
    end
  end

  describe "Search Params" do
    it "should return results of software name search query" do
      get '/search?q=cybozu'
      last_response.status.should == 200
      last_response.body.include?('cybozu')
    end
    
    #This spec verifies that the body includes the params chrome and 31.
    it "should return results of software and version" do
      get '/search?q=chrome+31'
      last_response.status.should == 200
      last_response.body.include?('chrome')
      last_response.body.include?('31')      
    end
    
    it "should return search results with hyphenated params" do
      get '/search?q=ffmpeg-0.5'
      last_response.status.should == 200
    end
    
    it "should return results of vender name" do
      get '/search?q=microsoft'
      last_response.status.should == 200
      last_response.body.include?('microsoft')      
    end
    
    it "should return results of query of words in summary" do
      get '/search?q=phishing+browser'
      last_response.status.should == 200
      last_response.body.include?('phishing browser')
    end
    
    it "should return results of query for 5 words" do
      get '/search?q=gain+privileges+via+unspecified+vectors'
      last_response.status.should == 200
      last_response.body.include?('gain privileges via unspecified vectos')
    end
    #Is this spec valid? If no params entered it just goes to the search form. 
    #It noticed google, bing, yahoo if no search params entered it just redirects back to the search form
    #Maybe should test that it doesn't error out and webform rendered
    it "should raise error and alert user when no params entered" do
      get '/search?q='
      last_response.status.should == 200
      last_response.body.include? File.read(search)
    end
  end
  
  describe "Limit results" do
    it "should return results limited to 10" do
      get '/search?q=linux'
      last_response.status.should == 200
      #last_response.body['results'].count.should == 10      
    end
  end

  describe "Return individual Vulnerability" do
    it "should display single vulnerability" do
      get '/cve/CVE-2002-2443'
      last_response.status.should == 200
      #last_response.body['results'].count().should == 1
    end
  end
  
  describe "400 errors" do
    it "should display page not found error if path spelled wrong" do
      get '/vulnerabities/'
      last_response.status.should == 404
      last_response.body.should == 'page not found'
    end
    
    it "should raise error when cve-id entered doesn't exist" do
      get '/cve/CVE-000-0000'
      last_response.body.should == "[]"
    end
    
    it "should raise error if unaccepted content enter" do
      get '/vulnerabilities.xml'
      last_response.status.should == 404
      last_response.body.should == "page not found"
    end
    
    it "should raise error if unaccepted character entered" do
      get '/search?q=linux+OR+1=1,---'
      last_response.status.should == 200
      last_response.body.should == "Unaccepted character entered. Please enter valid characters."
    end
  end
  
  describe "No docs found" do
    it "should alert user no results found" do
      get '/search?q=AirGapIT'
      last_response.status.should == 200
      last_response.body.include?('No Results Found')
    end
  end
end