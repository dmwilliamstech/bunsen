require File.expand_path '../spec_helper.rb', __FILE__

describe "Nist Application" do
  
  it "should respond to GET /" do
    get '/'
    last_response.status.should == 302

  end
  
  describe "Return all Vulnerabilities" do
    it "should display all vulnerabilities in sorted by alphabetically and by date_published" do
      get '/vulnerabilities/'
      last_response.status.should == 200
      #last_response.Content-Type.should == "application/json"
      puts last_response
    
    end
  end
  
  describe "Json functionality" do
    it "should return search results as JSON on the /search.json interface" do
      post '/search.json?q="google"'
      last_response.status.should == 200
      last_response.Content-Type.should == "application/json"
      last_response.status.Content-Disposition.should == "attachment; filename=\"<q>.json\""
    end
    
    it "should return all vulnerabilities as JSON on the /vulnerabilties.json interface" do
      get '/vulnerabilities.json'
      last_response.status.should == 200
      last_response.Content-Type.should == "application/json"
      last_response.status.Content-Disposition.should == "attachment; filename=\"vulnerabilities.json\""
    end
  
    describe "PDF functionality" do
      it "should return results as a valid PDF on the /search.pdf interface" do
        post '/search.pdf?q="google"'
        last_response.status.should == 200
        last_response.status.Content-Type.should == "application/pdf"
        last_response.status.Content-Disposition.should == "attachment; filename=\"<q>.pdf\""
        last_response.body.should ==""
      end
    
      it "should return all vulnerabilities as PDF on the /vulnerabilties.json interface" do
        get '/vulnerabilities.pdf'
        last_response.status.should == 200
        last_response.status.Content-Type.should == "application/pdf"
        last_response.status.Content-Disposition.should == "attachment; filename=\"allVulnerabilities.pdf\""
        last_response.body.should ==""
      end
    end
  
    describe "Search Params" do
      it "should return results of software name search query" do
        get '/search/?q="linux"'
        last_response.status.should == 200
        last_response.body['results'].should be_a_kind_of(Array)
        last_response.body['results'].should == ""
      end
    
      it "should return results of software and version" do
        get '/search/?q="chrome 31"'
        last_response.status.should == 200
        last_response.body['results'].should be_a_kind_of(Array)
        last_response.body['results'].should == ""      
      end
    
      it "should return results of vender name" do
        get '/search/?q="microsoft"'
        last_response.status.should == 200
        last_response.body['results'].should be_a_kind_of(Array)
        last_response.body['results'].should == ""      
      end
    
      it "should return results of query of words in summary" do
        get '/search/?q="remote attack"'
        last_response.status.should == 200
        last_response.body['results'].should be_a_kind_of(Array)
        last_response.body['results'].should == ""
      end
    
      it "should return results of query for 5 words" do
        get '/search/?q="gain privileges via unspecified vectors"'
        last_response.status.should == 200
        last_response.body['results'].should be_a_kind_of(Array)
        last_response.body['results'].should == ""
      end
      
      it "should raise error and alert user when no params entered" do
      get '/search/?q=""'
      last_response.should raise_error
    end
    end
  
    describe "Limit results" do
      it "should return results limited to 10" do
        get '/search/?q="linux"'
        last_response.status.should == 200
        last_response.body['results'].should be_a_kind_of(Array)
        last_response.body['results'].should == ""      
      end
    end

    describe "Return individual Vulnerability" do
      it "should display single vulnerability" do
        get '/vulnerabilities/<id>'
        last_response.status.should == 200
        last_response.Content-Type.should == "application/json"
        body = JSON.parse(last_response.body)
        body.should include('')
        puts last_response
      end
      it "should raise error when no cve-id entered" do
        get '/vulnerabilities/'
        last_response.should raise_error
      end
    end

  end