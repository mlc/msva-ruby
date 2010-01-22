require File.dirname(__FILE__) + '/spec_helper'

describe "msva-rb" do
  include Rack::Test::Methods

  def app
    @app ||= Sinatra::Application
  end

  def response_json
    yield JSON.parse(last_response.body)
  end

  describe "requesting /" do
    before do
      get '/'
    end

    it "should return a valid JSON document" do
      last_response.should be_ok
      last_response.headers["Content-Type"].should == "application/json"
      assert_nothing_raised do
        JSON.parse(last_response.body)
      end
    end

    it "should identify itself as MSVA-Ruby" do
      response_json do |json|
        json["server"].should_not be_nil
        json["server"].should be_a_kind_of String
        json["server"].should =~ /^MSVA-Ruby/
      end
    end

    it "should claim to speak protocol version 1" do
      response_json do |json|
        json["protoversion"].should be_a_kind_of Integer
        json["protoversion"].should == 1
      end
    end
  end

  it "should not accept a GET to /reviewcert" do
    get '/reviewcert'
    last_response.should_not be_ok
  end

  describe "reviewing a certificate" do
    before do
      @zimmermann = load_asset("zimmermann.der")
      @redhat = load_asset("redhat-ecc.der")
      @mlcastle = load_asset("mlcastle.der")
    end

    it "should fail with no JSON, without calling monkeysphere" do
      app.any_instance.expects(:'`').never
      # this is normal Rack::Test post method, not our special
      # json_post, so the provided data will be passed in as
      # application/x-www-form-urlencoded, and our application should
      # fail to parse it
      post '/reviewcert', {"whatever" => "yes"}
      response_json do |json|
        json["valid"].should be_false
        json["message"].should =~ /couldn't parse/
      end
    end

    it "should fail on empty JSON, without calling monkeysphere" do
      app.any_instance.expects(:'`').never
      json_post '/reviewcert', {}
      response_json do |json|
        json["valid"].should be_false
        json["message"].should =~ /pkc not present/
      end
    end

    it "should succeed when appropriate" do
      mock_zimmermann_call
      json_post '/reviewcert', proper_request
      response_json do |json|
        json["valid"].should be_true
      end
    end

    # if we make the monkeysphere support ECC, then this test will
    # need to be updated or removed
    it "should reject a non-RSA certificate" do
      app.any_instance.expects(:'`').never
      json_post '/reviewcert', proper_request.merge( :pkc => { :type => "x509der", :data => @redhat.to_byte_array } )
      response_json do |json|
        json["valid"].should be_false
        json["message"].should =~ /only RSA/
      end
    end

    # we're using zimmermann's X.509 certificate but otherwise
    # simulating example.com
    it "should NOT notice that the DER certificate fails to match the provided peer" do
      mock_zimmermann_call("example.com")
      json_post '/reviewcert', proper_request.merge( :peer => "example.com" )
      response_json do |json|
        json["valid"].should be_true
      end
    end

    it "should fail if nothing is found in the monkeysphere" do
      mock_zimmermann_call('zimmermann.mayfirst.org', '')
      json_post '/reviewcert', proper_request
      response_json do |json|
        json["valid"].should be_false
        json["message"].should =~ /No valid matching/
      end
    end

    it "shoulf fail if the cert in the monkeysphere is not a match" do
      mock_zimmermann_call
      json_post '/reviewcert', proper_request.merge( :pkc => { :type => "x509der", :data => @mlcastle.to_byte_array } )
      response_json do |json|
        json["valid"].should be_false
        json["message"].should =~ /No valid matching/
      end
    end

    def mock_zimmermann_call(host = "zimmermann.mayfirst.org", output = load_asset("ms-zimmermann-output"))
      app.any_instance.expects(:'`').with("monkeysphere u \"https://#{host}\"").returns(output)
    end

    def proper_request
      {
        :pkc => { :type => "x509der", :data => @zimmermann.to_byte_array },
        :context => "https",
        :peer => "zimmermann.mayfirst.org"
      }
    end
  end

  it "should handle not-found pages with a JSON 404" do
    get '/error'
    last_response.status.should == 404
    last_response.headers["Content-Type"].should == "application/json"
  end
end