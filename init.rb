require 'fileutils'

plugin_root = File.dirname(__FILE__)

config_file = File.join(plugin_root,'..','..','..','config','rcov_stats.yml')

unless File.exists?(config_file)
  use_rspec = File.exists?(File.join(RAILS_ROOT, 'spec'))
  config_file_base = (use_rspec ? 'rcov_rspec' : 'rcov_standard') + '.yml'
  FileUtils.cp(File.join(plugin_root, 'config', config_file_base), config_file)
end
