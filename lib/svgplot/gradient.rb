module SVGPlot
  ##
  # Helpers to add gradients to a tag
  module AddGradient
    def linear_gradient(id, attributes = {}, if_exists = :skip, &block)
      @img.add_def(id, LinearGradient.new(@img, attributes), if_exists, &block)
    end

    def radial_gradient(id, attributes = {}, if_exists = :skip, &block)
      @img.add_def(id, RadialGradient.new(@img, attributes), if_exists, &block)
    end
  end

  ##
  # SVG base gradient element, with ruby methods to describe the gradient
  class Gradient < ChildTag
    def fill
      "url(##{@attributes[:id]})"
    end

    def stop(offset, color, opacity)
      append_child(ChildTag.new(
        @img,
        'stop',
        'offset' => offset,
        'stop-color' => color,
        'stop-opacity' => opacity
      ))
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
