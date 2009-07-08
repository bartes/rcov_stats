module RcovStats

 class << self

    def  plugin_root
      File.join(File.dirname(__FILE__),'..')
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
      YAML::load(File.open(File.join(root ,'config','rcov_stats.yml')))[name]
    end
 
    def get_array_data(name)
       (get_config(name) || []).reject{|d| d.blank?}.uniq
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

    def excluded_paths
      %w(spec gems plugins)
    end

    def igonored_paths
      %w(. .. .svn)
    end

    def test_file_indicator
      "*_#{test_name}.rb"
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

    def parse_file_to_test(file_list)
      rcov_tests = []
      file_list.each do |f|
        dir_or_file = File.join(root, test_name,f)
        next unless File.exists?(dir_or_file)
        unless File.directory?(dir_or_file)
          rcov_tests << File.join(dir_or_file)
        else
          sub_elements = Dir.entries(dir_or_file) - igonored_paths
          next if sub_elements.size.zero?
          main_tests_not_included = true
          sub_elements.each do |sub_element|
            if File.directory?(File.join(dir_or_file,sub_element))
              rcov_tests << File.join(dir_or_file,sub_element,test_file_indicator)
            elsif main_tests_not_included
              rcov_tests << File.join(dir_or_file,test_file_indicator)
              main_tests_not_included = false
            end
          end
        end
      end
      rcov_tests
    end

    def parse_file_to_cover(file_list)
      rcov_covers = []
      file_list.each do |f|
        dir_or_file = File.join(root,f)
        next unless File.exists?(dir_or_file)
        unless File.directory?(dir_or_file)
          rcov_covers << f
        else
          sub_elements = Dir.entries(dir_or_file) - igonored_paths
          next if sub_elements.size.zero?
          main_tests_not_included = true
          sub_elements.each do |sub_element|
            if File.directory?(File.join(dir_or_file,sub_element))
              rcov_covers << File.join(f,sub_element)
            elsif main_tests_not_included
              rcov_covers << File.join(f)
              main_tests_not_included = false
            end
          end
        end
      end
      rcov_covers
    end

    def invoke_rcov_task(options)
      require 'rake/win32'
      files_to_cover = parse_file_to_cover(options[:files_to_cover].uniq).map{|f| "(#{f})".gsub("/","\/")}.join("|")
      rcov_settings = "--sort coverage --text-summary --rails  -x \"^(?!(#{files_to_cover}))\" "
      rcov_settings +="--exclude \"#{excluded_paths.map{|p| "#{p}/*"}.join(",")}\" "
      rcov_settings +="--output=#{File.join(root,"coverage",options[:output])} " if options[:output]
      rcov_tests = parse_file_to_test(options[:files_to_test].uniq)
      return false if rcov_tests.empty?
      rcov_settings += rcov_tests.join(' ')
      cmd = "rcov #{rcov_settings}"
      Rake::Win32.windows? ?  Rake::Win32.rake_system(cmd) : system(cmd)
    end

    def invoke_rcov_spec_task(options)
      require 'spec/rake/spectask'
      rcov_tests = parse_file_to_test(options[:files_to_test].uniq)
      return false if rcov_tests.empty?
      Spec::Rake::SpecTask.new(options[:name]) do |t|
        t.spec_opts = ['--options', "\"#{File.join(root,'spec','spec.opts')}\""]
        t.spec_files = rcov_tests
        t.rcov = true
        t.rcov_dir =  File.join(root,"coverage",options[:output]) if options[:output]
        files_to_cover = parse_file_to_cover(options[:files_to_cover].uniq).map{|f| "(#{f})".gsub("/","\/")}.join("|")
        t.rcov_opts = ["--rails","--text-summary","--sort","coverage","--exclude","\"#{excluded_paths.map{|p| "#{p}/*"}.join(",")}\"","-x" , "\"^(?!(#{files_to_cover}))\""]
      end
    end

    def invoke(type)
      options = {}
      case type.to_s
      when "units"
        options[:name] = "rcov:units"
        options[:files_to_cover] = units_files_to_cover
        options[:files_to_test] = units_files_to_test
        options[:output] = "units"
      when "functionals"
        options[:name] = "rcov:functionals"
        options[:files_to_cover] = functionals_files_to_cover
        options[:files_to_test] = functionals_files_to_test
        options[:output] = "functionals"
      when "general"
        options[:name] = "rcov:general"
        options[:files_to_cover] = units_files_to_cover + functionals_files_to_cover
        options[:files_to_test] = units_files_to_test + functionals_files_to_test
        options[:output] = nil
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
     Merb::Plugins.add_rakefiles(File.join(File.dirname(__FILE__),"rcov_stats_tasks"))
  end
end


plugin_root = File.dirname(__FILE__)
config_file = File.join(RCOV_STATS_ROOT,'config','rcov_stats.yml')

unless File.exists?(config_file)
  use_rspec = File.exists?(File.join(RCOV_STATS_ROOT, 'spec'))
  config_file_base = (use_rspec ? 'rcov_rspec' : 'rcov_standard') + '.yml'
  FileUtils.cp(File.join(plugin_root, 'config', config_file_base), config_file)
end


