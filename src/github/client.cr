require "http/client"
require "json"

module Github
  class Client
    @http : HTTP::Client?

    def http : HTTP::Client
      if !@http.nil?
        return @http.not_nil!
      end

      _http = HTTP::Client.new "api.github.com", port: 443, tls: true

      _http.before_request do |request|
        request.headers["Authorization"] = "token #{@token}"
      end

      @http = _http
      return _http
    end

    def initialize(@token : String, @repo = "miry/prcomment", @issue = 1)
    end

    def comments
      response = http.get "/repos/#{@repo}/issues/#{@issue}/comments"

      if response.status_code != 200 # => 200
        puts "Something goes wrong"
        puts response.status.code
        return [] of String
      end
      if response.body?
        return JSON.parse(response.body)
      end
      puts "Something goes wrong"
      puts response.status_code
      return [] of String
    end

    def create_comment(msg : String)
      response = http.post("/repos/#{@repo}/issues/#{@issue}/comments",
        headers: HTTP::Headers{"Authorization" => "token #{@token}"},
        body: %({"body": "#{msg}"))

      case response.status_code
      when 201
        puts "201: Successfuly created a comment"
      when 401
        puts "401: Requires authentication"
      when 403
        puts "403: Does not have access"
        puts response.body.lines
      else
        puts "Something goes wrong"
        puts response.status.code
        puts response.body.lines
      end
      nil
    end

    # https://developer.github.com/v3/issues/comments/#edit-a-comment
    def update_comment(id, msg : String)
      response = http.patch("/repos/#{@repo}/issues/comments/#{id}",
        headers: HTTP::Headers{"Authorization" => "token #{@token}"},
        body: %({"body": "#{msg}"))
      case response.status_code
      when 200
        puts "200: Successfuly updated the comment"
      when 401
        puts "401: Requires authentication"
      when 403
        puts "403: Does not have access"
        puts response.body.lines
      else
        puts "Something goes wrong"
        puts response.status.code
        puts response.body.lines
      end
      nil
    end

    def close
      http.close unless @http
    end
  end
end
