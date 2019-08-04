require "json"
require "http/client"

class PRComment
	@client : HTTP::Client
	def initialize
		@client = gh_client
	end

	def my_comment(pattern : Regex)
		result = comments
		if result.is_a?(JSON::Any)
			result.as_a.each do |comment|
				if pattern.match(comment["body"].to_s)
					return comment
				end
			end
		end
		nil
	end

	def comments
		response = @client.get "/repos/miry/prcomment/issues/1/comments"

		if response.status_code != 200     # => 200
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

	# https://developer.github.com/v3/issues/comments/#create-a-comment
	def create_comment(token, msg : String)
		response = @client.post("/repos/miry/prcomment/issues/1/comments",
					headers: HTTP::Headers{"Authorization" => "token #{token}"},
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
	def update_comment(token, id, msg : String)
		response = @client.patch("/repos/miry/prcomment/issues/comments/#{id}",
					headers: HTTP::Headers{"Authorization" => "token #{token}"},
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

	def gh_client
		HTTP::Client.new "api.github.com", port: 443, tls: true
	end

	def close
		@client.close unless @client.nil?
	end
end

token = ENV["GITHUB_TOKEN"]
tool = PRComment.new
comment = tool.my_comment(/First/i)
if comment
	tool.update_comment(token, comment["id"], "Seccond comment")
else
	tool.create_comment(token, "First comment")
end
tool.close
