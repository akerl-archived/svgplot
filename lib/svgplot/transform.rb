module SVGPlot
  ##
  # Provide methods for SVG transformations
  module Transforms
    # rubocop:disable Style/MethodName
    def translate(tx, ty = 0)
      add_transform(:translate, "#{tx}, #{ty}")
      self
    end

    def scale(sx, sy = 1)
      add_transform(:scale, "#{sx}, #{sy}")
      self
    end

    def rotate(angle, cx = nil, cy = nil)
      string = [cx, cy].any?(&:nil?) ?  "#{angle}" : "#{angle}, #{cx}, #{cy}"
      add_transform(:rotate, string)
      self
    end

    def skewX(angle)
      add_transform(:skewX, "#{angle}")
      self
    end

    def skewY(angle)
      add_transform(:skewY, "#{angle}")
      self
    end

    def matrix(*args)
      fail('matrix takes 6 args') unless args.size == 6
      add_transform(:matrix, args.join(', '))
      self
    end

    def linearGradient(id, attributes = {}, if_exists = :skip, &block)
      fail('image ref not set, cannot use linearGradient') if @img.nil?
      object = SVGPlot::SVGLinearGradient.new(@img, attributes)
      @img.add_def(id, object, if_exists, &block)
    end

    def radialGradient(id, attributes = {}, if_exists = :skip, &block)
      fail('image ref not set, cannot use radialGradient') if @img.nil?
      object = SVGPlot::SVGRadialGradient.new(@img, attributes)
      @img.add_def(id, object, if_exists, &block)
    end
    # rubocop:enable Style/MethodName
  end
end
