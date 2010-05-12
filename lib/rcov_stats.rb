require 'fileutils'
require "rexml/document"

class RcovStats

  TYPES = ["units", "functionals"]

  def self.cattr_accessor_with_default(name, value = nil)
    cattr_accessor name
    self.send("#{name}=", value) if value
  end

  cattr_accessor_with_default :is_rails, Object.const_defined?('Rails')
  cattr_accessor_with_default :is_merb, Object.const_defined?('Merb')
  cattr_accessor_with_default :root, ((@@is_rails && Rails.root) or (@@is_merb && Merb.root) or nil)
  cattr_accessor_with_default :rcov_stats_dir, File.dirname(__FILE__)
  cattr_accessor_with_default :rcov_stats_config_file, File.join(@@root, 'config', 'rcov_stats.yml')
  cattr_accessor_with_default :use_rspec, File.exists?(File.join(@@root, 'spec'))
  cattr_accessor_with_default :test_name, @@use_rspec ? "spec" : "test"
  cattr_accessor_with_default :test_file_indicator, "*_#{@@test_name}.rb"
  cattr_accessor_with_default :cover_file_indicator, "*.rb"

  attr_accessor :name, :sections

  def initialize(name_, sections_ = nil)
    self.name = name_
    self.sections = sections_.blank? ? [name_] : sections_
  end

  def self.get_config(option)
    YAML::load(File.open(File.join(@@root, 'config', 'rcov_stats.yml')))[option]
  end

  def self.before_rcov
    (pre_rcov = get_config("before_rcov")).blank? ? nil : pre_rcov
  end

  def get_array_data(type)
    @sections.map do |section|
      (self.class.get_config("#{section}_#{type}") || []).reject { |d| d.blank? }
    end.flatten.uniq
  end

  def files_to_cover
    get_array_data "files_to_cover"
  end

  def files_to_test
    get_array_data "files_to_test"
  end

  def parse_file_to_test(list)
    result = []
    list.each do |f|
      file_list = File.directory?(File.join(@@root, @@test_name, f)) ? File.join(@@test_name, f, "**", @@test_file_indicator) : File.join(@@test_name, f)
      unless (list_of_read_files = Dir[file_list]).empty?
        result += list_of_read_files
      end
    end
    result.uniq
  end

  def parse_file_to_cover(list)
    result = []
    list.each do |f|
      file_list = File.directory?(File.join(@@root, f)) ? File.join(f, "**", @@cover_file_indicator) : File.join(f)
      unless (list_of_read_files = Dir[file_list]).empty?
        result += list_of_read_files
      end
    end
    result.uniq
  end

  def invoke_rcov_task
    require 'rake/win32'
    files_to_cover_parsed = parse_file_to_cover(files_to_cover).map { |f| "(#{f})".gsub("/", "\/") }.join("|")
    rcov_settings = "--sort coverage --text-summary -x \"^(?!(#{files_to_cover_parsed}))\" "
    rcov_settings +="--output=#{File.join(@@root, "coverage", @name)} "
    rcov_tests = parse_file_to_test(files_to_test)
    return false if rcov_tests.empty?
    rcov_settings += rcov_tests.join(' ')
    cmd = "rcov #{rcov_settings}"
    Rake::Win32.windows? ? Rake::Win32.rake_system(cmd) : system(cmd)
  end

  def invoke_rcov_spec_task
    require 'spec/rake/spectask'
    rcov_tests = parse_file_to_test(files_to_test)
    return false if rcov_tests.empty?
    Spec::Rake::SpecTask.new(@name) do |t|
      spec_opts = File.join(@@root, @@test_name, 'spec.opts')
      t.spec_opts = ['--options', "\"#{spec_opts}\""] if File.exists?(spec_opts)
      t.spec_files = rcov_tests
      t.rcov = true
      t.rcov_dir =  File.join(@@root, "coverage", @name)
      files_to_cover_parsed = parse_file_to_cover(files_to_cover).map { |f| "(#{f})".gsub("/", "\/") }.join("|")
      t.rcov_opts = ["--text-summary", "--sort", "coverage", "-x", "\"^(?!(#{files_to_cover_parsed}))\""]
    end
  end

  def invoke
    @@use_rspec ? invoke_rcov_spec_task : invoke_rcov_task
  end

  def generate_index
    Dir[File.join(@@rcov_stats_dir, '..', 'templates/*')].each do |i|
      FileUtils.cp(i, File.join(@@root, 'coverage', i.split("/").last))
    end
    @sections.each do |i|
      coverage_index = File.join(@@root, 'coverage', i, "index.html")
      next unless File.exists?(coverage_index)
      isource = IO.read(coverage_index)
      idoc = REXML::Document.new(isource.gsub(/\&/, ""))
      footer_tts = idoc.get_elements("//tfoot/tr/td//tt")
      footer_div_covered = idoc.get_elements("//tfoot/tr/td//div[@class='covered']")
      footer_div_uncovered = idoc.get_elements("//tfoot/tr/td//div[@class='uncovered']")
      curr_source = IO.read(File.join(@@root, 'coverage', "index.html"))
      curr_source.gsub!("#{i}_total_lines", footer_tts[0].text)
      curr_source.gsub!("#{i}_code_lines", footer_tts[1].text)
      curr_source.gsub!("#{i}_total_result", footer_tts[2].text)
      curr_source.gsub!("#{i}_code_result", footer_tts[3].text)
      curr_source.gsub!("#{i}_total_rpx", footer_div_covered[0].attribute("style").value)
      curr_source.gsub!("#{i}_total_cpx", footer_div_covered[1].attribute("style").value)
      curr_source.gsub!("#{i}_total_lrpx", footer_div_uncovered[0].attribute("style").value)
      curr_source.gsub!("#{i}_total_lcpx", footer_div_uncovered[1].attribute("style").value)
      curr_source.gsub!(/\<p\>*\<\/p\>/, "Generated on #{Time.now}")
      File.open(File.join(@@root, 'coverage', "index.html"), "w+") do |f|
        f.write(curr_source)
      end
    end
  end

  def self.setup
    if @@is_merb
      Merb::Plugins.add_rakefiles(File.join(@@rcov_stats_dir, "rcov_stats_tasks"))
    end
    unless File.exists?(@@rcov_stats_config_file)
      which_conf_use = (@@use_rspec ? 'rcov_rspec' : 'rcov_standard') + '.yml'
      FileUtils.cp(File.join(@@rcov_stats_dir, '..', 'config', which_conf_use), @@rcov_stats_config_file)
    end
  end
end

RcovStats.setup



