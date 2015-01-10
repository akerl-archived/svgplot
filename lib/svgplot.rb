##
# SVG generation module
module SVGPlot
  class << self
    ##
    # Add .new() helper for creating a new Plot object

    def new(*args, &block)
      self::Plot.new(*args, &block)
    end
  end
end

require 'svgplot/spec'
require 'svgplot/application'
require 'svgplot/meta'
require 'svgplot/parsers'
require 'svgplot/transform'
require 'svgplot/defaults'
require 'svgplot/tag'
require 'svgplot/path'
require 'svgplot/gradient'
require 'svgplot/plot'
