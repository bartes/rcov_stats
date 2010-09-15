require "fileutils"
require "erb"
require "hpricot"
require 'rcov_stats_related/erb_binding'

class RcovStats

  TYPES = ["units", "functionals"]

  def self.cattr_accessor_with_default(name, value = nil)
    cattr_accessor name
    self.send("#{name}=", value) if value
  end

  cattr_accessor_with_default :is_rails, defined?(Rails)
  cattr_accessor_with_default :is_merb, defined?(Merb)

  def self.root
    "."
  end

  raise "Rcov Stats could not detect Rails or Merb framework" unless root
  
  cattr_accessor_with_default :rcov_stats_dir, File.dirname(__FILE__)
  cattr_accessor_with_default :rcov_stats_config_file, File.join(root, 'config', 'rcov_stats.yml')

  cattr_accessor_with_default :cover_file_indicator, "*.rb"

  attr_accessor :name, :sections



  def initialize(name_, sections_ = nil)
    self.name = name_
    self.sections = sections_.blank? ? [name_] : sections_
  end

  def self.get_config(option)
    YAML::load(File.open(File.join(root, 'config', 'rcov_stats.yml')))[option]
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
      file_list = File.directory?(File.join(self.class.root, test_name, f)) ? File.join(test_name, f, "**", test_file_indicator) : File.join(test_name, f)
      unless (list_of_read_files = Dir[file_list]).empty?
        result += list_of_read_files
      end
    end
    result.uniq
  end

  def parse_file_to_cover(list)
    result = []
    list.each do |f|
      file_list = File.directory?(File.join(self.class.root, f)) ? File.join(f, "**", self.class.cover_file_indicator) : File.join(f)
      unless (list_of_read_files = Dir[file_list]).empty?
        result += list_of_read_files
      end
    end
    result.uniq
  end

  def test_file_indicator
    "*_#{test_name}.rb"
  end

  def generate_index
    Dir[File.join(self.class.rcov_stats_dir, '..', 'templates/*')].each do |i|
      FileUtils.mkdir_p File.join(self.class.root, 'coverage')
      FileUtils.cp(i, File.join(self.class.root, 'coverage', i.split("/").last))
    end

    template_object = {}

    @sections.each do |i|
      FileUtils.mkdir_p File.join(self.class.root, 'coverage', i)
      coverage_index = File.join(self.class.root, 'coverage', i, "index.html")
      next unless File.exists?(coverage_index)
      doc = open(coverage_index) { |f| Hpricot(f) }
      footer_tts = doc.search("//tfoot/tr/td//tt")
      footer_div_covered = doc.search("//tfoot/tr/td//div[@class='covered']")
      footer_div_uncovered = doc.search("//tfoot/tr/td//div[@class='uncovered']")

      template_object["#{i}_total_lines"] = footer_tts[0].inner_text
      template_object["#{i}_code_lines"] =  footer_tts[1].inner_text
      template_object["#{i}_total_result"] = footer_tts[2].inner_text
      template_object["#{i}_code_result"] =  footer_tts[3].inner_text
      template_object["#{i}_total_rpx"] =  footer_div_covered[0].get_attribute("style")
      template_object["#{i}_total_cpx"] =  footer_div_covered[1].get_attribute("style")
      template_object["#{i}_total_lrpx"] = footer_div_uncovered[0].get_attribute("style")
      template_object["#{i}_total_lcpx"] =  footer_div_uncovered[1].get_attribute("style")
    end
    
    template_object["generated_on"] = "Generated on #{Time.now}"
    template_source = ERB.new(IO.read(File.join(self.class.root, 'coverage', "index.html")))

    File.open(File.join(self.class.root, 'coverage', "index.html"), "w+") do |f|
      f.write( template_source.result(RcovStatsRelated::ErbBinding.new(template_object).get_binding))
    end
  end

  def bundler?
    File.exist?("./Gemfile")
  end

  def self.setup
    if is_merb
      Merb::Plugins.add_rakefiles(File.join(rcov_stats_dir, "rcov_stats_tasks"))
    end

    if defined?(RSpec)
      require 'rcov_stats_related/integrations/rspec2'
      include RcovStatsRelated::Integrations::Rspec2
      which_conf_use =  'rcov_rspec'
    elsif defined?(Spec)
      require 'rcov_stats_related/integrations/rspec'
      include RcovStatsRelated::Integrations::Rspec
      which_conf_use =  'rcov_rspec'
    else
      require 'rcov_stats_related/integrations/test_unit'
      include RcovStatsRelated::Integrations::TestUnit
      which_conf_use = 'rcov_standard'
    end


    unless File.exists?(rcov_stats_config_file)
      which_conf_use += '.yml'
      FileUtils.cp(File.join(rcov_stats_dir, '..', 'config', which_conf_use), rcov_stats_config_file)
    end
  end
end


RcovStats.setup


