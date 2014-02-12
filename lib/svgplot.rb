##
# SVG generation module

module SVGPlot
    Version = '0.0.1'
    class << self
        ##
        # Add .new() helper for creating a new Plot object

        def new(*args)
            self::SVG.new(*args)
        end
    end

    ##
    # Plot object (represents an SVG image)

    class Plot
    end
end

require 'svgplot/spec'
require 'svgplot/meta'

