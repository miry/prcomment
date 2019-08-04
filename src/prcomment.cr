require "http/client"

class PRComment
  def initialize
    response = HTTP::Client.get "https://www.google.com"
    puts response.status_code      # => 200
    puts response.body.lines.first # => "<!doctype html>"
  end
end

PRComment.new
