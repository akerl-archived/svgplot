#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'pp'

file_path = 'lib/svgplot/svg_spec.rb'
version_url = "http://www.w3.org/TR/SVG11/"

elements = []
structure = {}

Nokogiri::HTML(open(version_url + 'eltindex.html')).css("li").each do |li|  
    name = li.css("span.element-name").children[0].text

    link = li.css("a")[0]['href']
    more = Nokogiri::HTML(open(version_url + link)).css('div.element-summary').find do |summary|
        summary.css('div.element-summary-name').children[0].text == name
    end

    tag = name[1..-2].to_sym
    structure[tag] = {
        :elements => more.css('span.element-name').map { |s| s.children[0].text[1..-2].to_sym },
        :attributes => more.css('span.attr-name').map { |s| s.children[0].text[1..-2].to_sym },
    }

    elements << name[1..-2].to_sym
    print '.'
end
puts

xmlns = [
    "svg",
    "cc",
    "dc",
    "rdf",
    "inkscape",
    "xlink",
].map! { |e| ("xmlns:" + e).to_sym }
structure[:svg][:attributes].push(:xmlns, *xmlns)

File.open(file_path, 'w') do |file|
    file << "Rasem::SVG_ELEMENTS = \n"
    PP.pp(elements,file)
    file << "Rasem::SVG_STRUCTURE = \n"
    PP.pp(structure,file)
end

