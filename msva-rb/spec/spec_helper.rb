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
require 'json'

# set test environment
set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false
