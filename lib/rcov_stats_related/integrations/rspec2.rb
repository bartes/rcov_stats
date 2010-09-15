module RcovStatsRelated
  module Integrations
    module Rspec2

      def invoke
        require 'rspec/core/rake_task'

        rcov_tests = parse_file_to_test(files_to_test)
        return false if rcov_tests.empty?
        RSpec::Core::RakeTask.new(@name) do |t|
          t.pattern = rcov_tests
          t.rcov = true
          t.rcov_path =  File.join(self.class.root, "coverage", @name)
          files_to_cover_parsed = parse_file_to_cover(files_to_cover).map { |f| "(#{f})".gsub("/", "\/") }.join("|")
          t.rcov_opts = ["--text-summary", "--sort", "coverage", "-x", "\"^(?!(#{files_to_cover_parsed}))\""]
        end
      end

      def test_name
        "spec"
      end
    end
  end
end
