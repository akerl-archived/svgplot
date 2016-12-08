Gem::Specification.new do |s|
  s.name        = 'svgplot'
  s.version     = '1.0.0'
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
  s.executables = ['svgplot']

  s.add_development_dependency 'rubocop', '~> 0.46.0'
  s.add_development_dependency 'rake', '~> 12.0.0'
  s.add_development_dependency 'codecov', '~> 0.1.1'
  s.add_development_dependency 'rspec', '~> 3.5.0'
  s.add_development_dependency 'fuubar', '~> 2.2.0'
  s.add_development_dependency 'nokogiri', '~> 1.6.5'
end
