namespace :rcov do
  require File.join(File.dirname(__FILE__), "../lib/rcov_stats.rb")
  desc "run rcov for units tests"
  task :units => RcovStats.before_rcov do
    puts '** rcov:units **'
    RcovStats.invoke('units')
  end
  
  desc "run rcov for functionals tests"
  task :functionals => RcovStats.before_rcov do
    puts '** rcov:functionals **'
    RcovStats.invoke('functionals')
  end

  desc "run rcov for functionals and units tests"
  task :stats => RcovStats.before_rcov do
    puts '** rcov:stats **'
    RcovStats.invoke('units')
    RcovStats.invoke('functionals')
  end

  desc "run general rcov tests"
  task :general => RcovStats.before_rcov do
    puts '** rcov:general **'
    RcovStats.invoke('general')
  end
end
