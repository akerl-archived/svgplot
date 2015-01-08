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
require 'svgplot/raw'
require 'svgplot/gradients'
require 'svgplot/paths'
require 'svgplot/transform'
require 'svgplot/plot'
