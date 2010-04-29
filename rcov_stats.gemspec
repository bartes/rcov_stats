Gem::Specification.new do |gemspec|
    gemspec.name = %q{rcov_stats}
    gemspec.version = "2.0.0"
    gemspec.authors = ["Bartosz Knapik"]
    gemspec.date = %q{2010-04-29}
    gemspec.description = %q{Rcov Stats provides rcov extension, so you could select test files and test covered files for units and functionals tests.}
    gemspec.email = %q{bartesrlz_at_gmail.com}
    gemspec.homepage = %q{http://www.lunarlogicpolska.com}
    gemspec.files = %w(lib/rcov_stats.rb lib/rcov_stats_tasks.rb tasks/rcov.rake
                       config/rcov_standard.yml config/rcov_rspec.yml
                       templates/print.css templates/screen.css templates/index.html
                       templates/rcov.js templates/jquery-1.3.2.min.js templates/jquery.tablesorter.min.js
                       README init.rb Rakefile MIT-LICENSE)
    gemspec.summary = %q{Rcov Stats provides rcov extension, so you could select test files and test covered files for units and functionals tests.}
    gemspec.add_dependency 'rcov'
end
