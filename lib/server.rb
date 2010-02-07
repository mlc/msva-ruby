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

module Msva
  class Server < Sinatra::Application
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

    post '/reviewcert', :provides => "application/json" do
      content_type "application/json"
      Msva::Validator.reviewcert(params).to_json
    end

    post '/reviewcert', :provides => 'text/html' do
      ret = Msva::Validator.reviewcert(params)
      @valid = ret[:valid]
      @message = ret[:message]
      erb :reviewcert
    end

    # TODO: fill in if we need to do so
    # post '/extracerts' do
    # end

    not_found do
      content_type "application/json"

      { :status => 404, :message => "not found" }.to_json
    end
  end
end
