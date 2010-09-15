module RcovStatsRelated
  module Integrations
    module Rspec

      def invoke
        require 'spec/rake/spectask'

        rcov_tests = parse_file_to_test(files_to_test)
        return false if rcov_tests.empty?
        Spec::Rake::SpecTask.new(@name) do |t|
          t.spec_files = rcov_tests
          t.rcov = true
          begin
            t.rcov_dir =  File.join(self.class.root, "coverage", @name)
          rescue
          end
          files_to_cover_parsed = parse_file_to_cover(files_to_cover).map { |f| "(#{f})".gsub("/", "\/") }.join("|")
          t.rcov_opts = ["--text-summary", "--sort", "coverage", "--output", "#{File.join(self.class.root, "coverage", @name)}", "--exclude", "\"^(?!(#{files_to_cover_parsed}))\""]
        end
      end

      def test_name
        "spec"
      end 
    end
  end
end