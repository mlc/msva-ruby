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
      set :root, File.join(File.dirname(__FILE__), "..")

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

    OUR_TYPES = ["text/html", "application/xhtml+xml", "application/json"]

    before do
      @response_type = MIMEParse.best_match(OUR_TYPES, env["HTTP_ACCEPT"] || "*/*")
      unless @response_type && !@response_type.empty?
        halt 406, { 'Content-Type' => 'text/plain' }, "sorry, we can only serve HTML, XHTML, or JSON\n"
      end

      @html = @response_type != "application/json"
      content_type @response_type + (@html ? "; charset=utf-8" : '')

    end

    get '/' do
      if @html
        @git_rev = @@git_rev
        erb :about
      else
        result = { :available => true, :protoversion => 1, :server => "MSVA-Ruby 0.01" }
        result[:git_revision] = @@git_rev if @@git_rev
        result.to_json
      end
    end

    post '/reviewcert' do
      result = Msva::Validator.reviewcert(params)
      if @html
        @valid = result[:valid]
        @message = result[:message]
        erb :reviewcert
      else
          result.to_json
      end
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
