require "option_parser"

module PRComment
  class Command
    def self.run
      token = ENV.fetch("GITHUB_TOKEN", "")
      repo = ENV.fetch("GITHUB_REPOSITORY", ENV.fetch("GITHUB_ACTION_REPOSITORY", ""))
      issue_id : UInt64 = 0
      ref : String = ENV.fetch("GITHUB_REF", "")

      begin
        id = ENV.fetch("GITHUB_ISSUE", ENV.fetch("INPUT_PR", "0"))
        issue_id = id.to_u64 if id.size > 0
      rescue ArgumentError
        # Ignore all conversation errors
      end

      msg = ""
      match = ""
      full_cmd = "#{PROGRAM_NAME} #{ARGV.join(" ")}"

      parser = OptionParser.parse do |parser|
        parser.banner = "Usage: #{PROGRAM_NAME} [arguments]"
        parser.on("-r REPO", "--repo=GITHUB_REPOSITORY", "Github repo name. E.g: miry/prcomment") { |r| repo = r }
        parser.on("-i ISSUE", "--issue=GITHUB_ISSUE", "Specify to which issue attach a comment") { |i|
          begin
            issue_id = i.to_u64
          rescue
            STDERR.puts "cmd: #{full_cmd}"
            STDERR.puts "error: flag --issue expects number\n\n"
            exit 1
          end
        }
        parser.on("-t TOKEN", "--token=GITHUB_TOKEN", "Specify token to create comments") { |t| token = t }
        parser.on("-m MATCH", "--match=TEXT", "Setup pattern for replace comment") { |m| match = m }
        parser.on("-h", "--help", "Show this help") { exit 0 }

        parser.unknown_args do |before, after|
          msg = (before | after).join(" ")
        end
      end

      validate!(issue_id, ref, repo, token, parser)

      msg = STDIN.gets_to_end if msg == ""

      tool = ::PRComment::Tool.new(token, repo, issue_id)
      tool.post(msg, match)
      tool.close
    end

    def self.validate!(issue_id, ref, repo, token, parser)
      full_cmd = "#{PROGRAM_NAME} #{ARGV.join(" ")}"

      if issue_id == 0 && ref.starts_with?("refs/pull/")
        issue_id = ref.split("/")[-2].to_u64
      end

      if issue_id == 0
        STDERR.puts "error: github issue is required"
        STDERR.puts "cmd: #{full_cmd}"
        STDERR.puts "env:"
        ["GITHUB_ISSUE", "GITHUB_ACTION_REPOSITORY", "GITHUB_REF"].each do |k|
          STDERR.puts "  #{k} = '#{ENV.fetch(k, "")}'"
        end
        puts parser
        exit 1
      end

      if repo == ""
        STDERR.puts "error: github repo name is required"
        STDERR.puts "cmd: #{full_cmd}"
        STDERR.puts "env:"
        ["GITHUB_REPOSITORY", "INPUT_PR"].each do |k|
          STDERR.puts "  #{k} = '#{ENV.fetch(k, "")}'"
        end
        puts parser
        exit 1
      end

      if token == ""
        STDERR.puts "error: github token is required"
        STDERR.puts "cmd: #{full_cmd}"
        STDERR.puts "env:\n  GITHUB_TOKEN - is #{ENV.has_key?("GITHUB_TOKEN") ? "existed" : "missing"}"
        puts parser
        exit 1
      end
    end
  end
end
