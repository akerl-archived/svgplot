#!/usr/bin/env ruby

require 'nokogiri'
require 'open-uri'
require 'pp'

file_path = 'lib/svgplot/spec.rb'
version_url = 'http://www.w3.org/TR/SVG11/'

elements = []
structure = {}

page = open(version_url + 'eltindex.html') # rubocop:disable Security/Open

Nokogiri::HTML(page).css('li').each do |li|
  name = li.css('span.element-name').children[0].text

  link = li.css('a')[0]['href']
  link_page = open(version_url + link) # rubocop:disable Security/Open
  divs = Nokogiri::HTML(link_page).css('div.element-summary')
  more = divs.find do |summary|
    summary.css('div.element-summary-name').children[0].text == name
  end

  tag = name[1..-2].to_sym
  structure[tag] = {
    elements: more.css('span.element-name').map do |s|
      s.children[0].text[1..-2].to_sym
    end,
    attributes: more.css('span.attr-name').map do |s|
      s.children[0].text[1..-2].to_sym
    end
  }

  elements << name[1..-2].to_sym
  print '.'
end
puts

xmlns = %w[svg cc dc rdf inkscape xlink].map! { |e| ('xmlns:' + e).to_sym }
structure[:svg][:attributes].push(:xmlns, *xmlns)

skipped_cops = %w[
  Layout/SpaceAroundOperators
  Layout/SpaceInsideHashLiteralBraces
  Style/HashSyntax
  Style/SymbolArray
  Layout/IndentAssignment
  Style/MutableConstant
]

File.open(file_path, 'w') do |file|
  skipped_cops.each { |cop| file << "# rubocop:disable #{cop}\n" }
  file << "SVGPlot::SVG_ELEMENTS =\n"
  PP.pp(elements, file)
  file << "SVGPlot::SVG_STRUCTURE =\n"
  PP.pp(structure, file)
  skipped_cops.each { |cop| file << "# rubocop:enable #{cop}\n" }
end
