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
require 'svgplot/meta'
