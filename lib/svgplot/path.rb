# rubocop:disable Metrics/ParameterLists
module SVGPlot
  # SVG Path element, with ruby methods to describe the path
  class Path < ChildTag
    def initialize(img, attributes = {})
      attributes[:d] ||= ''
      super(img, 'path', attributes)
    end

    ##
    # Moves pen to specified point x,y without drawing.
    def move_to(x, y)
      add_d("m#{x},#{y}")
    end

    def move_to_a(x, y)
      add_d("M#{x},#{y}")
    end

    ##
    # Draws a line from current pen location to specified point x,y.
    def line_to(x, y)
      add_d("l#{x},#{y}")
    end

    def line_to_a(x, y)
      add_d("L#{x},#{y}")
    end

    ##
    # Draws a horizontal line to the point defined by x.
    def hline_to(x)
      add_d("h#{x}")
    end

    def hline_to_a(x)
      add_d("H#{x}")
    end

    ##
    # Draws a vertical line to the point defined by y.
    def vline_to(y)
      add_d("v#{y}")
    end

    def vline_to_a(y)
      add_d("V#{y}")
    end

    ##
    # Draws a cubic Bezier curve from current pen point to dx,dy.
    # x1,y1 and x2,y2 are start and end control points of the curve,
    # controlling how it bends.
    def curve_to(dx, dy, x1, y1, x2, y2)
      add_d("c#{x1},#{y1} #{x2},#{y2} #{dx},#{dy}")
    end

    def curve_to_a(dx, dy, x1, y1, x2, y2)
      add_d("C#{x1},#{y1} #{x2},#{y2} #{dx},#{dy}")
    end

    ##
    # Draws a cubic Bezier curve from current pen point to dx,dy. x2,y2 is the
    # end control point. The start control point is is assumed to be the same
    # as the end control point of the previous curve.
    def scurve_to(dx, dy, x2, y2)
      add_d("s#{x2},#{y2} #{dx},#{dy}")
    end

    def scurve_to_a(dx, dy, x2, y2)
      add_d("S#{x2},#{y2} #{dx},#{dy}")
    end

    ##
    # Draws a quadratic Bezier curve from current pen point to dx,dy. x1,y1 is
    # the control point controlling how the curve bends.
    def qcurve_to(dx, dy, x1, y1)
      add_d("q#{x1},#{y1} #{dx},#{dy}")
    end

    def qcurve_to_a(dx, dy, x1, y1)
      add_d("Q#{x1},#{y1} #{dx},#{dy}")
    end

    ##
    # Draws a quadratic Bezier curve from current pen point to dx,dy. The
    # control point is assumed to be the same as the last control point used.
    def sqcurve_to(dx, dy)
      add_d("t#{dx},#{dy}")
    end

    def sqcurve_to_a(dx, dy)
      add_d("T#{dx},#{dy}")
    end

    ##
    # Draws an elliptical arc from the current point to the point x,y. rx and ry
    # are the elliptical radius in x and y direction.
    # The x-rotation determines how much the arc is to be rotated around the
    # x-axis. It only has an effect when rx and ry have different values.
    # The large-arc-flag doesn't seem to be used (can be either 0 or 1). Neither
    # value (0 or 1) changes the arc.
    # The sweep-flag determines the direction to draw the arc in.
    def arc_to(dx, dy, rx, ry, axis_rot, large_arc_flag, sweep_flag)
      add_d(
        "a#{rx},#{ry} #{axis_rot} #{large_arc_flag},#{sweep_flag} #{dx},#{dy}"
      )
    end

    def arc_to_a(dx, dy, rx, ry, axis_rot, large_arc_flag, sweep_flag)
      add_d(
        "A#{rx},#{ry} #{axis_rot} #{large_arc_flag},#{sweep_flag} #{dx},#{dy}"
      )
    end

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
      @attributes[:d] << " #{op}"
    end
  end
end
