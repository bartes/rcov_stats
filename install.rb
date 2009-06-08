require 'fileutils'

plugin_root = File.dirname(__FILE__)

puts "\n\ninstalled rcov_stats\n\n"
puts IO.read(File.join(plugin_root, 'README'))