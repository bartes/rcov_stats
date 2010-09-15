module RcovStats
  module Integrations
    module Rspec

      def invoke
        require 'spec/rake/spectask'

        rcov_tests = parse_file_to_test(files_to_test)
        return false if rcov_tests.empty?
        Spec::Rake::SpecTask.new(@name) do |t|
          spec_opts = File.join(self.class.root, self.class.test_name, 'spec.opts')
          t.spec_opts = ['--options', "\"#{spec_opts}\""] if File.exists?(spec_opts)
          t.spec_files = rcov_tests
          t.rcov = true
          t.rcov_dir =  File.join(self.class.root, "coverage", @name)
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