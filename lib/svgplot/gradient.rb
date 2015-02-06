module SVGPlot
  ##
  # SVG base gradient element, with ruby methods to describe the gradient
  class Gradient < ChildTag
    def fill
      "url(##{@attributes[:id]})"
    end

    def stop(offset, color, opacity)
      append_child(
        ChildTag.new(
          @img,
          'stop',
          'offset' => offset,
          'stop-color' => color,
          'stop-opacity' => opacity
        )
      )
    end
  end

  ##
  # linear gradient element
  class LinearGradient < Gradient
    def initialize(img, attributes = {}, &block)
      super(img, 'linearGradient', attributes, &block)
    end
  end

  ##
  # radial gradient element
  class RadialGradient < Gradient
    def initialize(img, attributes = {}, &block)
      super(img, 'radialGradient', attributes, &block)
    end
  end
end
