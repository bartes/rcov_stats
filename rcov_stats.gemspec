Gem::Specification.new do |s|
  s.name = %q{rcov_stats}
  s.version = "1.0.0"
  s.authors = ["Bartosz Knapik"]
  s.date = %q{2009-07-08}
  s.description = %q{Rcov Stats provides rcov extenstion, so you could select test files and test covered files for units and functionals tests.}
  s.email = %q{bartesrlz_at_gmail.com}
  s.has_rdoc = false
  s.homepage = %q{http://www.lunarlogicpolska.com}
  s.files = Dir['lib/*'] + Dir['tasks/*']  + Dir['config/*'] + %w(README init.rb Rakefile MIT-LICENSE)
  s.summary = %q{Rcov Stats provides rcov extenstion, so you could select test files and test covered files for units and functionals tests.}
  s.add_dependency('rake', '>= 0.8.7')
  s.required_ruby_version = '>= 1.8.6'
end