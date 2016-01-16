module SVGPlot
  ##
  # Provide methods for SVG transformations
  module Transform
    def translate(tx, ty = 0)
      add_transform(:translate, "#{tx}, #{ty}")
      self
    end

    def scale(sx, sy = 1)
      add_transform(:scale, "#{sx}, #{sy}")
      self
    end

    def rotate(angle, cx = nil, cy = nil)
      string = [cx, cy].any?(&:nil?) ? angle.to_s : "#{angle}, #{cx}, #{cy}"
      add_transform(:rotate, string)
      self
    end

    def skew_x(angle)
      add_transform(:skewX, angle.to_s)
      self
    end

    def skew_y(angle)
      add_transform(:skewY, angle.to_s)
      self
    end

    def matrix(*args)
      fail('matrix takes 6 args') unless args.size == 6
      add_transform(:matrix, args.join(', '))
      self
    end

    private

    def add_transform(type, params)
      validate_attribute(:transform)
      @attributes[:transform] ||= ''
      @attributes[:transform] << ' ' if @attributes[:transform].size > 0
      @attributes[:transform] << "#{type}(#{params})"
    end
  end
end
