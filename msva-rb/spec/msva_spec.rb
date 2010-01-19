require File.dirname(__FILE__) + '/spec_helper'

describe "msva-rb" do
  include Rack::Test::Methods

  def app
    @app ||= Sinatra::Application
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
      json = JSON.parse(last_response.body)
      json["server"].should_not be_nil
      json["server"].should be_a_kind_of String
      json["server"].should =~ /^MSVA-Ruby/
    end

    it "should speak protocol version 1" do
      json = JSON.parse(last_response.body)
      json["protoversion"].should be_a_kind_of Integer
      json["protoversion"].should == 1
    end
  end

  describe "reviewing a certificate" do

  end

  it "should handle not-found pages with a JSON 404" do
    get '/error'
    last_response.status.should == 404
    last_response.headers["Content-Type"].should == "application/json"
  end
end
