require File.join(File.dirname(__FILE__), '..', 'server.rb')

begin
  require 'rubygems'
rescue LoadError
  # hope for the best!
end

require 'sinatra'
require 'rack/test'
require 'spec'
require 'spec/autorun'
require 'spec/interop/test'
require 'mocha'
require 'json'

Spec::Runner.configure do |conf|
  conf.mock_with :mocha
end

# set test environment
set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

# some helper methods
def load_asset(filename)
  File.read(File.join(File.dirname(__FILE__), "data", filename))
end

class String
  def to_byte_array
    unpack("C*")
  end
end

class Rack::Test::Session
  def json_post(uri, body, options = {})
    post uri, {}, options.merge(:input => JSON(body), :content_type => "application/json")
  end
end

module Rack::Test::Methods
  def_delegator :current_session, :json_post
end
