module PRComment
  class Tool
    @client : Github::Client

    def initialize(token : String, repo : String, issue : UInt64)
      @client = Github::Client.new(token, repo, issue)
    end

    def my_comment(pattern : Regex) : JSON::Any?
      result = @client.comments
      if result.is_a?(JSON::Any)
        result.as_a.each do |comment|
          if pattern.match(comment["body"].to_s)
            return comment
          end
        end
      end
      nil
    end

    def post(msg : String, match = "") : Nil
      if match == ""
        match = msg
      end

      comment = my_comment(/#{match}/i)
      if comment
        update_comment(comment["id"], msg)
      else
        create_comment(msg)
      end
    end

    def update_comment(comment_id, msg : String) : Nil
      @client.update_comment(comment_id, msg)
    end

    def create_comment(msg : String) : Nil
      @client.create_comment(msg)
    end

    def close : Nil
      @client.close unless @client.nil?
    end
  end
end
