begin
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = %q{rcov_stats}
    gemspec.version = "1.0.0"
    gemspec.authors = ["Bartosz Knapik"]
    gemspec.date = %q{2009-07-08}
    gemspec.description = %q{Rcov Stats provides rcov extension, so you could select test files and test covered files for units and functionals tests.}
    gemspec.email = %q{bartesrlz_at_gmail.com}
    gemspec.has_rdoc = false
    gemspec.homepage = %q{http://www.lunarlogicpolska.com}
    gemspec.files = Dir['lib/*'] + Dir['tasks/*']  + Dir['config/*'] + %w(README init.rb Rakefile MIT-LICENSE)
    gemspec.summary = %q{Rcov Stats provides rcov extension, so you could select test files and test covered files for units and functionals tests.}
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
