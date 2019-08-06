require "./github/*"

class PRComment
  @client : Github::Client

  def initialize(token : String)
    @client = Github::Client.new(token, repo: "miry/prcomment", issue: 1)
  end

  def my_comment(pattern : Regex)
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

  def post(msg : String)
    comment = my_comment(/#{msg}/i)
    if comment
      update_comment(comment["id"], msg)
    else
      create_comment(msg)
    end
  end

  def update_comment(comment_id, msg : String)
    @client.update_comment(comment_id, msg)
  end

  def create_comment(msg : String)
    @client.create_comment(msg)
  end

  def close
    @client.close unless @client.nil?
  end
end

token = ENV["GITHUB_TOKEN"]
tool = PRComment.new(token)
tool.post("First comment")
tool.close
