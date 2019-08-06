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
        request.headers["Content-Type"] = "application/json"
        request.headers["Authorization"] = "token #{@token}"
      end

      @http = _http
      return _http
    end

    def request(method, endpoint, headers : HTTP::Headers? = nil, body : String? = nil)
      response = http.exec(method.upcase, endpoint, headers, body)

      puts "#{method} #{endpoint} => #{response.status_code} #{response.status_message}"

      case response.status_code
      when 200..299
      else
        puts response.status.code
        puts response.body.lines
        raise "Something goes wrong"
      end

      JSON.parse(response.body)
    end

    def get(endpoint, headers : HTTP::Headers? = nil, body : String? = nil)
      request "GET", endpoint, headers, body
    end

    def post(endpoint, headers : HTTP::Headers? = nil, body : String? = nil)
      request "POST", endpoint, headers, body
    end

    def patch(endpoint, headers : HTTP::Headers? = nil, body : String? = nil)
      request "PATCH", endpoint, headers, body
    end

    def initialize(@token : String, @repo : String, @issue : Int64)
    end

    # https://developer.github.com/v3/issues/comments/#list-comments-on-an-issue
    def comments
      get "/repos/#{@repo}/issues/#{@issue}/comments"
    end

    # https://developer.github.com/v3/issues/comments/#create-a-comment
    def create_comment(msg : String)
      post("/repos/#{@repo}/issues/#{@issue}/comments",
        headers: HTTP::Headers{"Authorization" => "token #{@token}"},
        body: %({"body": "#{msg}"))
      nil
    end

    # https://developer.github.com/v3/issues/comments/#edit-a-comment
    def update_comment(id, msg : String)
      patch("/repos/#{@repo}/issues/comments/#{id}",
        headers: HTTP::Headers{"Authorization" => "token #{@token}"},
        body: %({"body": "#{msg}"))
    end

    def close
      http.close unless @http
    end
  end
end
