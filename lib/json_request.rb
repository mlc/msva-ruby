# override parameter parsing from Sinatra / Rack to enable automagic
# parsing of JSON input in addition to application/x-www-form-urlencoded

class Rack::Request
  alias_method :POST_without_json, :POST
  
  def POST
    return self.POST_without_json unless media_type && media_type == 'application/json'

    @env["rack.request.form_hash"] ||= JSON.parse(@env["rack.input"].read)
  end
end
