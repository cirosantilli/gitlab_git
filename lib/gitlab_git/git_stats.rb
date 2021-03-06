require_relative 'log_parser'

module Gitlab
  module Git
    class GitStats
      attr_accessor :repo, :ref, :timeout

      def initialize(repo, ref, timeout = 30)
        @repo, @ref, @timeout = repo, ref, timeout
      end

      def log
        log = nil
        Grit::Git.with_timeout(timeout) do
          # Limit log to 6k commits to avoid timeout for huge projects
          args = [ref, '-6000', '--format=%aN%x0a%aE%x0a%cd', '--date=short', '--shortstat', '--no-merges', '--diff-filter=ACDM']
          log = repo.git.native(:log, {}, args)
        end

        log
      rescue Grit::Git::GitTimeout
        nil
      end

      def parsed_log
        LogParser.parse_log(log)
      end
    end
  end
end
