require File.expand_path '../spec_helper.rb', __FILE__

describe NewVuls do
  describe "grab xml" do
    context "go to nist" do
      it "if nist site is up"
      request = Net::HTTP.get_response(URI.parse('http://nvd.nist.gov'))
      request.code.should == "200"
    end

    context "get and convert xml to json" do
      it "verify content type"
      request = Net::HTTP.get_response(URI.parse('http://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-recent.xml'))
      request.content_type.should == 'text/xml'
    
      it "if successfully convert to json"
      JSON.pretty_generate(Hash.from_xml(request.body)["nvd"])
    end
  end
  
end
  
  