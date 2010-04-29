module RcovStats

  class << self

    def plugin_root
      File.join(File.dirname(__FILE__), '..')
    end

    def is_rails?
      Object.const_defined?('RAILS_ROOT')
    end

    def is_merb?
      Object.const_defined?('Merb')
    end

    def root
      root_dir = RAILS_ROOT if is_rails?
      root_dir = Merb.root if is_merb?
      root_dir
    end

    def get_config(name)
      YAML::load(File.open(File.join(root, 'config', 'rcov_stats.yml')))[name]
    end

    def get_array_data(name)
      (get_config(name) || []).reject { |d| d.blank? }.uniq
    end

    def units_files_to_cover
      get_array_data "units_files_to_cover"
    end

    def functionals_files_to_cover
      get_array_data "functionals_files_to_cover"
    end

    def units_files_to_test
      get_array_data "units_files_to_test"
    end

    def functionals_files_to_test
      get_array_data "functionals_files_to_test"
    end

    def ignored_paths
      %w( . .. .svn .git )
    end

    def test_file_indicator
      "*_#{test_name}.rb"
    end

    def cover_file_indicator
      "*.rb"
    end

    def before_rcov
      (pre_rcov = get_config("before_rcov")).blank? ? nil : pre_rcov
    end

    def use_rspec?
      File.exists?(File.join(root, 'spec'))
    end

    def test_name
      use_rspec? ? "spec" : "test"
    end

    def parse_file_to_test(list)
      result = []
      list.each do |f|
        file_list = File.directory?(File.join(root, test_name,  f)) ? File.join(test_name, f, "**", test_file_indicator) : File.join(test_name, f)
        unless (list_of_read_files = Dir[file_list]).empty?
          result += list_of_read_files
        end
      end
      result.uniq
    end

    def parse_file_to_cover(list)
      result = []
      list.each do |f|
        file_list = File.directory?(File.join(root, f)) ? File.join(f, "**", cover_file_indicator) : File.join(f)
        unless (list_of_read_files = Dir[file_list]).empty?
          result += list_of_read_files
        end
      end
      result.uniq
    end

    def invoke_rcov_task(options)
      require 'rake/win32'
      files_to_cover = parse_file_to_cover(options[:files_to_cover].uniq).map { |f| "(#{f})".gsub("/", "\/") }.join("|")
      rcov_settings = "--sort coverage --text-summary -x \"^(?!(#{files_to_cover}))\" "
      rcov_settings +="--output=#{File.join(root, "coverage", options[:output])} " if options[:output]
      rcov_tests = parse_file_to_test(options[:files_to_test].uniq)
      return false if rcov_tests.empty?
      rcov_settings += rcov_tests.join(' ')
      cmd = "rcov #{rcov_settings}"
      Rake::Win32.windows? ? Rake::Win32.rake_system(cmd) : system(cmd)
    end

    def invoke_rcov_spec_task(options)
      require 'spec/rake/spectask'
      rcov_tests = parse_file_to_test(options[:files_to_test].uniq)
      return false if rcov_tests.empty?
      Spec::Rake::SpecTask.new(options[:name]) do |t|
        spec_opts = File.join(root, 'spec', 'spec.opts')
        t.spec_opts = ['--options', "\"#{spec_opts}\""] if File.exists?(spec_opts)
        t.spec_files = rcov_tests
        t.rcov = true
        t.rcov_dir =  File.join(root, "coverage", options[:output]) if options[:output]
        files_to_cover = parse_file_to_cover(options[:files_to_cover].uniq).map { |f| "(#{f})".gsub("/", "\/") }.join("|")
        t.rcov_opts = ["--text-summary", "--sort", "coverage", "-x", "\"^(?!(#{files_to_cover}))\""]
      end
    end

    def invoke(type)
      options = {}
      case type.to_s
        when "units"
          options[:name] = "rcov:units"
          options[:files_to_cover] = units_files_to_cover.to_a
          options[:files_to_test] = units_files_to_test.to_a
          options[:output] = "units"
        when "functionals"
          options[:name] = "rcov:functionals"
          options[:files_to_cover] = functionals_files_to_cover.to_a
          options[:files_to_test] = functionals_files_to_test.to_a
          options[:output] = "functionals"
        when "general"
          options[:name] = "rcov:general"
          options[:files_to_cover] = units_files_to_cover.to_a + functionals_files_to_cover.to_a
          options[:files_to_test] = units_files_to_test.to_a + functionals_files_to_test.to_a
          options[:output] = "general"
        else
          raise "Not implemented task for that rcov #{type}"
      end
      use_rspec? ? invoke_rcov_spec_task(options) : invoke_rcov_task(options)
    end
  end

end

require 'fileutils'

unless  Object.const_defined?('RCOV_STATS_ROOT')
  RCOV_STATS_ROOT = RAILS_ROOT if RcovStats.is_rails?
  RCOV_STATS_ROOT = Merb.root if RcovStats.is_merb?
  if RcovStats.is_merb?
    Merb::Plugins.add_rakefiles(File.join(File.dirname(__FILE__), "rcov_stats_tasks"))
  end
end


file_path = File.dirname(__FILE__)
config_file = File.join(RCOV_STATS_ROOT, 'config', 'rcov_stats.yml')

unless File.exists?(config_file)
  use_rspec = File.exists?(File.join(RCOV_STATS_ROOT, 'spec'))
  config_file_base = (use_rspec ? 'rcov_rspec' : 'rcov_standard') + '.yml'
  FileUtils.cp(File.join(file_path, '..', 'config', config_file_base), config_file)
end


