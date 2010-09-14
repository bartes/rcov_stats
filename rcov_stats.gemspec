Gem::Specification.new do |gemspec|
    gemspec.name = %q{rcov_stats}
    gemspec.version = "2.1.1"
    gemspec.authors = ["Bartosz Knapik"]
    gemspec.date = Time.now.strftime("%Y-%m-%d")
    gemspec.description = %q{Rcov Stats provides rcov extension, so you could select test files and test covered files for units and functionals tests.}
    gemspec.email = %q{bartesrlz_at_gmail.com}
    gemspec.homepage = %q{http://github.com/bartes/rcov_stats}
    gemspec.files = Dir['lib/*.rb'] + Dir['config/*.yml'] +  Dir['templates/*.*'] +  Dir['tasks/*.*']
    gemspec.files += %w(README init.rb Rakefile MIT-LICENSE CHANGELOG)
    gemspec.summary = %q{Rcov Stats provides rcov extension, so you could select test files and test covered files for units and functionals tests.}
    gemspec.add_dependency('rcov', '~> 0.9.9')
    gemspec.add_dependency('hpricot', '~> 0.8.2')
    gemspec.add_dependency('rake', '~> 0.8.7')
end


