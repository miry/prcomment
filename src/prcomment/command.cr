require "option_parser"

module PRComment
  class Command
    # version ::PRComment::VERSION

    # class Help
    #   header "Creates or updates single comment to Github PR or Issue."
    #   footer "(C) Michael Nikitochkin <miry.sof@gmail.com>"
    # end

    # class Options
    #   string ["-i", "--issue"], desc: "Issue or PR number of the repo. E.g: 132", required: true
    #   string ["-r", "--repo"], desc: "Repo name of Github project. E.g: miry/prcomment", required: true
    #   string ["-t", "--token"], desc: "Github personal token. Could be set via env variable GITHUB_TOKEN."
    #   arg "msg", desc: "Github personal token. Could be set via env variable GITHUB_TOKEN.", required: true
    #   help
    # end

    def self.run
      token = ENV.fetch("GITHUB_TOKEN", "")
      repo = ENV.fetch("GITHUB_REPO", "")
      issue_id : UInt64 = ENV.fetch("GITHUB_ISSUE", "0").to_u64
      msg = ""
      match = ""
      exit = false

      OptionParser.parse! do |parser|
        parser.banner = "Usage: prcomment [arguments]"
        parser.on("-r REPO", "--repo=GITHUB_REPO", "Github repo name. E.g: miry/prcomment") { |r| repo = r }
        parser.on("-i ISSUE", "--issue=GITHUB_ISSUE", "Specify to which issue attach a comment") { |i| issue_id = i.to_u64 }
        parser.on("-t TOKEN", "--token=GITHUB_TOKEN", "Specify token to create comments") { |t| token = t }
        parser.on("-m MATCH", "--match=TEXT", "Setup pattern for replace comment") { |m| match = m }
        parser.on("-h", "--help", "Show this help") { puts parser; exit = true }

        parser.unknown_args do |before, after|
          msg = (before | after).join(" ")
        end
      end

      return if exit

      if repo == "" || token == "" || issue_id == 0 || msg == ""
        raise "Missing required arguments"
      end

      tool = ::PRComment::Tool.new(token, repo, issue_id)
      tool.post(msg, match)
      tool.close
    end
  end
end
