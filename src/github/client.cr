require "http/client"
require "json"

require "./connection"
require "./client/comments"

module Github
  class Client
    @http : HTTP::Client?

    include Github::Connection
    include Github::Client::Comments

    def initialize(@token : String, @repo : String, @issue : UInt64)
    end

    def close
      http.close unless @http
    end
  end
end
