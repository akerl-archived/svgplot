module SVGPlot
  # SVG base gradient element, with ruby methods to describe the gradient
  class SVGGradient < SVGPlot::SVGTagWithParent
    def fill
      "url(##{@attributes[:id]})"
    end

    def stop(offset, color, opacity)
      append_child(SVGPlot::SVGTag.new(
        'stop',
        'offset' => offset,
        'stop-color' => color,
        'stop-opacity' => opacity
      ))
    end
  end

  # SVG linear gradient element
  class SVGLinearGradient < SVGPlot::SVGGradient
    def initialize(img, attributes = {}, &block)
      super(img, 'linearGradient', attributes, &block)
    end
  end

  # SVG radial gradient element
  class SVGRadialGradient < SVGPlot::SVGGradient
    def initialize(img, attributes = {}, &block)
      super(img, 'radialGradient', attributes, &block)
    end
  end
end
