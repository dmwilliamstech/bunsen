require File.expand_path '../spec_helper.rb', __FILE__

disAll = File.join(File.dirname(__FILE__), 'spec_files', 'displayAll.json')
google = File.join(File.dirname(__FILE__), 'spec_files', 'google.json')
gpvuv = File.join(File.dirname(__FILE__),  'spec_files','gail privileges via unspecified vectors.json')
phishBrow = File.join(File.dirname(__FILE__), 'spec_files', 'phishing browser.json')
microsoft = File.join(File.dirname(__FILE__), 'spec_files', 'microsoft.json')
cybozu = File.join(File.dirname(__FILE__), 'spec_files', 'cybozu.json')
chrome31 = File.join(File.dirname(__FILE__), 'spec_files', 'chrome 31.json')
cveId = File.join(File.dirname(__FILE__), 'spec_files', 'CVE-2013-3907.json')

describe "Nist Application" do
  

  it "should respond to GET /" do
    get '/'
    #This is just a placeholder for now.
    last_response.body.should == "Use man curl for information on curl'ing. curl -H 'Accept: application/pdf;' http://localhost:4567/search 'q=<params>' "
    last_response.status.should == 200

  end
  
  describe "Return all Vulnerabilities" do
    it "should display all vulnerabilities" do
      get '/vulnerabilities/'
      last_response.status.should == 200
      JSON.parse(last_response.body).should == JSON.parse(File.read(disAll))
      puts last_response
    
    end
  end
  
  describe "Json functionality" do
    it "should return search results as JSON on the /search.json interface" do
      post '/search.json?q="google"'
      last_response.status.should == 200
      last_response.Content-Type.should == "application/json"
      JSON.parse(last_response.body).should == JSON.parse(File.read(google))
    end
    
    it "should return all vulnerabilities as JSON on the /vulnerabilties.json interface" do
      get '/vulnerabilities.json'
      last_response.status.should == 200
      last_response.Content-Type.should == "application/json"
      JSON.parse(last_response.body).should == JSON.parse(File.read(cveId))
    end
  end
  
  describe "PDF functionality" do
    it "should return results as a valid PDF on the /search.pdf interface" do
      post '/search.pdf?q="google"'
      last_response.status.should == 200
      last_response.status.Content-Type.should == "application/pdf"
      last_response.status.Content-Disposition.should == "attachment; filename=\"<q>.pdf\""
    end
    
    it "should return all vulnerabilities as PDF on the /vulnerabilties.pdf interface" do
      get '/vulnerabilities.pdf'
      last_response.status.should == 200
      last_response.status.Content-Type.should == "application/pdf"
      last_response.status.Content-Disposition.should == "attachment; filename=\"allVulnerabilities.pdf\""
    end
  end
  
  describe "Search Params" do
    it "should return results of software name search query" do
      get '/search?q="cybozu"'
      last_response.status.should == 200
      last_response.body['results'].should be_a_kind_of(Array)
      last_response.body['results'].should == JSON.parse(File.read(cybozu))
    end
    
    it "should return results of software and version" do
      get '/search?q="chrome 31"'
      last_response.status.should == 200
      selector('#results').should_not be_nil
      last_response.body['results'].should be_a_kind_of(Array)
      last_response.body['results'].should == JSON.parse(File.read(chrome31))      
    end
    
    it "should return results of vender name" do
      get '/search?q="microsoft"'
      last_response.status.should == 200
      selector('#results').should_not be_nil
      last_response.body['results'].should be_a_kind_of(Array)
      last_response.body['results'].should == JSON.parse(File.read(microsoft))      
    end
    
    it "should return results of query of words in summary" do
      get '/search?q="phishing browser"'
      last_response.status.should == 200
      selector('#results').should_not be_nil
      last_response.body['results'].should be_a_kind_of(Array)
      last_response.body['results'].should == JSON.parse(File.read(phishBrow)) 
    end
    
    it "should return results of query for 5 words" do
      get '/search?q="gain privileges via unspecified vectors"'
      last_response.status.should == 200
      last_response.body['results'].should be_a_kind_of(Array)
      last_response.body['results'].should == JSON.parse(File.read(gpvuv))
    end
      
    it "should raise error and alert user when no params entered" do
      get '/search?q=""'
      last_response.should raise_error
    end
  end
  
  describe "Limit results" do
    it "should return results limited to 10" do
      get '/search?q="linux"'
      last_response.status.should == 200
      last_response.body['results'].should be_a_kind_of(Array)
      last_response.body['results'].count().should == "10"      
    end
  end

  describe "Return individual Vulnerability" do
    it "should display single vulnerability" do
      get '/vulnerabilities/<id>'
      last_response.status.should == 200
      last_response.Content-Type.should == "application/json"
      last_response.body['results'].count().should == "1"
      puts last_response
    end
    it "should raise error when no cve-id entered" do
      get '/vulnerabilities/'
      last_response.should raise_error
    end
  end

end