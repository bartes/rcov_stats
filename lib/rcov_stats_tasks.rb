namespace :rcov do
  require File.join(File.dirname(__FILE__), "rcov_stats.rb")
  desc "run rcov for units tests"
  task(RcovStats.before_rcov ? ({:units => RcovStats.before_rcov}) : :units) do
    puts '** rcov:units **'
    RcovStats.invoke('units')
  end

  desc "run rcov for functionals tests"
  task(RcovStats.before_rcov ? ({:functionals => RcovStats.before_rcov}) : :functionals) do
    puts '** rcov:functionals **'
    RcovStats.invoke('functionals')
  end

  desc "run rcov for functionals and units tests"
  task(RcovStats.before_rcov ? ({:stats => RcovStats.before_rcov}) : :stats) do
    puts '** rcov:stats **'
    Rake::Task['rcov:units'].invoke
    Rake::Task['rcov:functionals'].invoke
  end

  desc "run general rcov tests"
  task(RcovStats.before_rcov ? ({:general => RcovStats.before_rcov}) : :general) do
    puts '** rcov:general **'
    RcovStats.invoke('general')
  end

  desc "generate index for all suites"
  task :generate_index do
    puts '** rcov:generate_index **'
    RcovStats.generate_index
  end
end
