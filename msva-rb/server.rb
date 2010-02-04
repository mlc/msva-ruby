#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# first:
# $ sudo aptitude install ruby libopenssl-ruby libsinatra-ruby libjson-ruby thin
# then:
# $ ./msva-rb/server.rb -p 8901

# Monkeysphere Validation Agent, Ruby version
# Copyright © 2010 Michael Castleman <m@mlcastle.net>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

$: << File.expand_path(File.dirname(__FILE__))

begin
  require 'rubygems'
rescue LoadError
  $stderr.puts "WARNING: Couldn't load rubygems; attempting to proceed without it..."
end

require 'erb'
require 'json'
require 'openssl'
require 'sinatra'

require 'opensshpubkey'

configure do
  git_dir = File.join(File.dirname(__FILE__), "..", ".git")
  if File.directory?(git_dir)
    @@git_rev = begin
                  `git show-ref -h HEAD --hash`.strip
                rescue
                  nil
                end
  else
    @@git_rev = nil
  end
end

get '/', :provides => "application/json" do
  content_type "application/json"

  result = { :available => true, :protoversion => 1, :server => "MSVA-Ruby 0.01" }
  result[:git_revision] = @@git_rev if @@git_rev
  result.to_json
end

get '/', :provides => "text/html" do
  content_type "text/html; charset=utf-8"
  @git_rev = @@git_rev
  erb :about
end

post '/reviewcert' do
  content_type "application/json"

  begin
    params = JSON.parse(request.body.string)
  rescue JSON::ParserError
    halt({ :valid => false, :message => "couldn't parse JSON query"}.to_json)
  end

  unless params.is_a?(Hash)
    halt({ :valid => false, :message => "provided JSON query must be a hash"}.to_json)
  end

  unless (params["pkc"] && params["pkc"]["type"] == "x509der")
    halt({ :valid => false, :message => "pkc not present or of not-understood type" }.to_json)
  end

  data = params["pkc"]["data"].pack("C*")
  ssl_pkey = OpenSSL::X509::Certificate.new(data).public_key

  unless ssl_pkey.is_a?(OpenSSL::PKey::RSA)
    halt({ :valid => false, :message => "only RSA keys supported for now"}.to_json)
  end

  uid = params["context"] + "://" + params["peer"]
  # FIXME: properly escape this shell command
  `monkeysphere u "#{uid}"`.lines do |line|
    proto, key = line.strip.split(' ', 2)
    unless proto == "ssh-rsa"
      $stderr.puts "WARNING: non-rsa key type #{proto} found!"
      next
    end

    monkey_pkey = OpenSshPubKey.new(key)
    if (monkey_pkey.n == ssl_pkey.n) && (monkey_pkey.e == ssl_pkey.e)
      halt({ :valid => true, :message => "#{uid} validated with Monkeysphere" }.to_json)
    end
  end
  
  { :valid => false, :message => "No valid matching OpenPGP keys found for #{uid}" }.to_json
end

# TODO: fill in if we need to do so
# post '/extracerts' do
# end

not_found do
  content_type "application/json"

  { :status => 404, :message => "not found" }.to_json
end
