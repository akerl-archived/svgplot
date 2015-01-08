module SVGPlot
  # inherit from tag for basic functionality, control raw data using write
  class SVGRaw < SVGPlot::SVGTagWithParent
    def initialize(img, data)
      @img = img
      @data = data
    end

    def write(output)
      output << @data.to_s
    end
  end
end
