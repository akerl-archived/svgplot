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
require 'svgplot/transforms'
require 'svgplot/tags'
require 'svgplot/raw'
require 'svgplot/gradients'
require 'svgplot/paths'
require 'svgplot/plot'
