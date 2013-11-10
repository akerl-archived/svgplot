$:.push File.expand_path("../lib", __FILE__)
require 'svgplot'

Gem::Specification.new do |s|
    s.name        = 'svgplot'
    s.version     = SVGPlot::Version
    s.date        = Time.now.strftime("%Y-%m-%d")

    s.summary     = 'SVG Generation Library'
    s.description = "Ruby interface for creating SVG images"
    s.authors     = ['Les Aker']
    s.email       = 'me@lesaker.org'
    s.homepage    = 'https://github.com/akerl/svgplot'
    s.license     = 'MIT'

    s.files       = `git ls-files`.split

    s.add_development_dependency 'nokogiri'
end

