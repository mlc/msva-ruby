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
    end

    it "should fail on empty JSON, without calling monkeysphere" do
      app.any_instance.expects(:'`').never
      json_post '/reviewcert', {}
      response_json do |json|
        json["valid"].should be_false
      end
    end

    it "should succeed when appropriate" do
      mock_zimmermann_call
      json_post '/reviewcert', {
        :pkc => { :type => "x509der", :data => @zimmermann.to_byte_array },
        :context => "https",
        :peer => "zimmermann.mayfirst.org"
      }
      response_json do |json|
        json["valid"].should be_true
      end
    end

    # if we make the monkeysphere support ECC, then this test will
    # need to be updated or removed
    it "should reject a non-RSA certificate" do
      app.any_instance.expects(:'`').never
      json_post '/reviewcert', {
        :pkc => { :type => "x509der", :data => @redhat.to_byte_array },
        :context => "https",
        :peer => "zimmermann.mayfirst.org"
      }
      response_json do |json|
        json["valid"].should be_false
      end
    end

    # we're using zimmermann's X.509 certificate but otherwise
    # simulating example.com
    it "should NOT notice that the DER certificate fails to match the provided peer" do
      mock_zimmermann_call("example.com")
      json_post '/reviewcert', {
        :pkc => { :type => "x509der", :data => @zimmermann.to_byte_array },
        :context => "https",
        :peer => "example.com"
      }
      response_json do |json|
        json["valid"].should be_true
      end
    end

    def mock_zimmermann_call(host = "zimmermann.mayfirst.org")
      app.any_instance.expects(:'`').with("monkeysphere u \"https://#{host}\"").returns(load_asset("ms-zimmermann-output"))
    end
  end

  it "should handle not-found pages with a JSON 404" do
    get '/error'
    last_response.status.should == 404
    last_response.headers["Content-Type"].should == "application/json"
  end
end
