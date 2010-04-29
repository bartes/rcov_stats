#TODO : improve that
require 'fileutils'

config_file = File.join(RAILS_ROOT, 'config', 'rcov_stats.yml')

File.delete(config_file) if File.exists?(config_file)

