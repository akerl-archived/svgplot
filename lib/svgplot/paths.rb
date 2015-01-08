module SVGPlot
  # SVG Path element, with ruby methods to describe the path
  class SVGPath < SVGPlot::SVGTagWithParent
    def initialize(img = nil, attributes = {})
      attributes.merge!(d: '') unless attributes.key? :d
      super(img, 'path', attributes)
    end

    # rubocop:disable Metrics/ParameterLists, Style/MethodName

    ##
    # moveTo commands
    #
    # Moves pen to specified point x,y without drawing.
    #
    ##
    def moveTo(x, y)
      add_d("m#{x},#{y}")
    end

    def moveToA(x, y)
      add_d("M#{x},#{y}")
    end

    ##
    # lineTo commands
    #
    # Draws a line from current pen location to specified point x,y.
    #
    ##
    def lineTo(x, y)
      add_d("l#{x},#{y}")
    end

    def lineToA(x, y)
      add_d("L#{x},#{y}")
    end

    ##
    # horizontal lineTo commands
    #
    # Draws a horizontal line to the point defined by x.
    #
    ##
    def hlineTo(x)
      add_d("h#{x}")
    end

    def hlineToA(x)
      add_d("H#{x}")
    end

    ##
    # vertical lineTo commands
    #
    # Draws a vertical line to the point defined by y.
    #
    ##
    def vlineTo(y)
      add_d("v#{y}")
    end

    def vlineToA(y)
      add_d("V#{y}")
    end

    ##
    # curveTo commands
    #
    # Draws a cubic Bezier curve from current pen point to dx,dy.
    # x1,y1 and x2,y2 are start and end control points of the curve,
    # controlling how it bends.
    #
    ##
    def curveTo(dx, dy, x1, y1, x2, y2)
      add_d("c#{x1},#{y1} #{x2},#{y2} #{dx},#{dy}")
    end

    def curveToA(dx, dy, x1, y1, x2, y2)
      add_d("C#{x1},#{y1} #{x2},#{y2} #{dx},#{dy}")
    end

    ##
    # smooth curveTo commands
    #
    # Draws a cubic Bezier curve from current pen point to dx,dy. x2,y2 is the
    # end control point. The start control point is is assumed to be the same
    # as the end control point of the previous curve.
    #
    ##
    def scurveTo(dx, dy, x2, y2)
      add_d("s#{x2},#{y2} #{dx},#{dy}")
    end

    def scurveToA(dx, dy, x2, y2)
      add_d("S#{x2},#{y2} #{dx},#{dy}")
    end

    ##
    # quadratic Bezier curveTo commands
    #
    # Draws a quadratic Bezier curve from current pen point to dx,dy. x1,y1 is
    # the control point controlling how the curve bends.
    #
    ##
    def qcurveTo(dx, dy, x1, y1)
      add_d("q#{x1},#{y1} #{dx},#{dy}")
    end

    def qcurveToA(dx, dy, x1, y1)
      add_d("Q#{x1},#{y1} #{dx},#{dy}")
    end

    ##
    # smooth quadratic Bezier curveTo commands
    #
    # Draws a quadratic Bezier curve from current pen point to dx,dy. The
    # control point is assumed to be the same as the last control point used.
    #
    ##
    def sqcurveTo(dx, dy)
      add_d("t#{dx},#{dy}")
    end

    def sqcurveToA(dx, dy)
      add_d("T#{dx},#{dy}")
    end

    ##
    # elliptical arc commands
    #
    # Draws an elliptical arc from the current point to the point x,y. rx and ry
    # are the elliptical radius in x and y direction.
    # The x-rotation determines how much the arc is to be rotated around the
    # x-axis. It only has an effect when rx and ry have different values.
    # The large-arc-flag doesn't seem to be used (can be either 0 or 1). Neither
    # value (0 or 1) changes the arc.
    # The sweep-flag determines the direction to draw the arc in.
    #
    ##
    def arcTo(dx, dy, rx, ry, axis_rot, large_arc_flag, sweep_flag)
      add_d(
        "a#{rx},#{ry} #{axis_rot} #{large_arc_flag},#{sweep_flag} #{dx},#{dy}"
      )
    end

    def arcToA(dx, dy, rx, ry, axis_rot, large_arc_flag, sweep_flag)
      add_d(
        "A#{rx},#{ry} #{axis_rot} #{large_arc_flag},#{sweep_flag} #{dx},#{dy}"
      )
    end

    # rubocop:enable Metrics/ParameterLists, Style/MethodName

    ##
    # close path command
    #
    # Closes the path by drawing a line from current point to first point.
    #
    ##
    def close
      add_d('Z')
    end

    private

    def add_d(op)
      @attributes[:d] = "#{@attributes[:d]} #{op}"
    end
  end
end
