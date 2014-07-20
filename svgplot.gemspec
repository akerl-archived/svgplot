Gem::Specification.new do |s|
  s.name        = 'svgplot'
  s.version     = '0.0.1'
  s.date        = Time.now.strftime("%Y-%m-%d")

  s.summary     = 'SVG Generation Library'
  s.description = 'Ruby interface for creating SVG images'
  s.authors     = [
                    'Les Aker',
                    'Vytis Valentinavičius',
                    'Jonathan Slate',
                    'Ahmed Eldawy'
                  ]
  s.email       = 'EMAIL_ADDRESS'
  s.homepage    = 'https://github.com/AUTHOR_NAME/REPO_NAME'
  s.license     = 'MIT'

  s.files       = `git ls-files`.split
  s.test_files  = `git ls-files spec/*`.split

  s.add_development_dependency 'rubocop', '~> 0.24.0'
  s.add_development_dependency 'rake', '~> 10.3.2'
  s.add_development_dependency 'coveralls', '~> 0.7.0'
  s.add_development_dependency 'rspec', '~> 3.0.0'
  s.add_development_dependency 'fuubar', '~> 2.0.0.rc1'
  s.add_development_dependency 'nokogiri', '~> 1.6.2.1'
end
