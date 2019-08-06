module Github
  class Error < Exception
    def self.from_response(response : HTTP::Client::Response)
      klass = case response.status_code
              when 400..499 then Github::ClientError
              when 500..599 then Github::ServerError
              end
      if klass
        klass.new(response)
      end
    end

    @data : JSON::Any? = nil

    def initialize(@response : HTTP::Client::Response = nil)
      super(build_error_message)
    end

    def build_error_message
      return nil if @response.nil?

      message = "#{@response.status_code} #{@response.status_message} "
      message += "#{response_message} " if response_message
      message += " // See: #{documentation_url}" unless documentation_url.nil?

      message
    end

    def response_message
      if data
        data.not_nil!["message"]
      end
    end

    def documentation_url
      if data
        data.not_nil!["documentation_url"]
      end
    end

    private def data
      return @data if @data

      if @response.body
        _data = JSON.parse(@response.body)
        @data = _data
      end

      return @data
    end
  end

  class ClientError < Error; end

  class ServerError < Error; end
end
