require "./github/*"

class PRComment
  @client : Github::Client

  def initialize(token : String, repo : String, issue : Int64)
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

  def post(msg : String) : Nil
    comment = my_comment(/#{msg}/i)
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

token = ENV["GITHUB_TOKEN"]
repo = "miry/prcomment"
issue_id : Int64 = 1
msg = "Second comment"

tool = PRComment.new(token, repo, issue_id)
tool.post(msg)
tool.close
