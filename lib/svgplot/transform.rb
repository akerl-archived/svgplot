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
      add_transform(:rotate, "#{angle}#{(cx.nil? or cy.nil?) ? "" : ", #{cx}, #{cy}"}")
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

    def matrix(a, b, c, d, e, f)
      add_transform(:matrix, "#{a}, #{b}, #{c}, #{d}, #{e}, #{f}")
      self
    end
  end
end
