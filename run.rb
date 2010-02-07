#!/usr/bin/env ruby

# first:
# $ sudo aptitude install ruby libopenssl-ruby libsinatra-ruby libjson-ruby thin
# then:
# ./run.rb

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

begin
  require 'rubygems'
rescue LoadError
  $stderr.puts "WARNING: Couldn't load rubygems; attempting to proceed without it..."
end

require 'erb'
require 'json'
require 'openssl'
require 'sinatra/base'

require 'lib/json_request'
require 'lib/monkeysphere'
require 'lib/server'
require 'lib/opensshpubkey'

Msva::Server.run! :host => 'localhost', :port => 8901
