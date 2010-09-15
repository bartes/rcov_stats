module RcovStatsRelated
  module Integrations
    module TestUnit

      def invoke
        require 'rake/win32'
        files_to_cover_parsed = parse_file_to_cover(files_to_cover).map { |f| "(#{f})".gsub("/", "\/") }.join("|")
        rcov_settings = "--sort coverage --text-summary --exclude \"^(?!(#{files_to_cover_parsed}))\" "
        rcov_settings +="--output=#{File.join(self.class.root, "coverage", @name)} "
        rcov_tests = parse_file_to_test(files_to_test)
        return false if rcov_tests.empty?
        rcov_settings += rcov_tests.join(' ')
        cmd = "#{'bundle exec' if bundler?} rcov #{rcov_settings}"
        Rake::Win32.windows? ? Rake::Win32.rake_system(cmd) : system(cmd)
      end

      def test_name
        "test"
      end 
    end
  end
end

