# frozen_string_literal: true

module Overcommit::Hook::PreCommit
    # Runs `golint` against any modified Golang files.
    #
    # @see https://github.com/golang/lint
    class CrystalFormat < Base
      def run
        errors = []
        applicable_files.each do |file|
          result = execute(command, args: [file])
          errors << (result.stdout + result.stderr) unless result.success?
        end
        return :pass if errors.empty?

        [:fail, errors.join("\n")]
      end
    end
  end
