module Github
  class Client
    module Comments
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
    end
  end
end
