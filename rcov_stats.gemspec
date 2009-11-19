Gem::Specification.new do |gemspec|
    gemspec.name = %q{rcov_stats}
    gemspec.version = "1.1.5"
    gemspec.authors = ["Bartosz Knapik"]
    gemspec.date = %q{2009-07-08}
    gemspec.description = %q{Rcov Stats provides rcov extension, so you could select test files and test covered files for units and functionals tests.}
    gemspec.email = %q{bartesrlz_at_gmail.com}
    gemspec.homepage = %q{http://www.lunarlogicpolska.com}
    gemspec.files = %w(lib/rcov_stats.rb lib/rcov_stats_tasks.rb tasks/rcov.rake config/rcov_standard.yml config/rcov_rspec.yml README init.rb Rakefile MIT-LICENSE)
    gemspec.summary = %q{Rcov Stats provides rcov extension, so you could select test files and test covered files for units and functionals tests.}
    gemspec.add_dependency 'rcov'
end
