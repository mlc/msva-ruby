$: << File.join(File.dirname(__FILE__), "..", "lib")

begin
  require 'rubygems'
rescue LoadError
  # hope for the best!
end

require 'sinatra/base'
require 'rack/test'
require 'spec'
require 'spec/autorun'
require 'spec/interop/test'
require 'mocha'
require 'json'

require 'json_request'
require 'mimeparse'
require 'monkeysphere'
require 'server'
require 'opensshpubkey'

Spec::Runner.configure do |conf|
  conf.mock_with :mocha
end

# set test environment
Msva::Server.set :environment, :test
Msva::Server.set :raise_errors, true
Msva::Server.set :logging, false

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
    post uri, {}, options.merge(:input => JSON(body), "CONTENT_TYPE" => "application/json", "HTTP_ACCEPT" => "application/json")
  end
end

module Rack::Test::Methods
  def_delegator :current_session, :json_post
end
