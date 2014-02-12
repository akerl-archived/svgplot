SVGPlot::SVG_ALIAS = {
  :group  => :g,
  :rectangle => :rect,
}

SVGPlot::SVG_EXPANSION = {
  :line   => [:x1,:y1,:x2,:y2],
  :circle => [:cx,:cy,:r],
  :image  => [:x,:y,:width,:height,:"xlink:href"],
  :ellipse => [:cx,:cy,:rx,:ry],
  :text   => [:x,:y],

  :rect   => lambda do |args|
        raise "Wrong unnamed argument count" unless args.size == 4 or args.size == 5 or args.size == 6
  result = {
    :x => args[0],
    :y => args[1],
    :width => args[2],
    :height => args[3],
  }
  if (args.size > 4)
    result[:rx] = args[4]
    result[:ry] = (args[5] or args[4])
  end
  return result
  end,

  :polygon => lambda do |args|
  args.flatten!
  raise "Illegal number of coordinates (should be even)" if args.length.odd?
  return {
    :points => args
  }
  end,

  :polyline => lambda do |args|
  args.flatten!
  raise "Illegal number of coordinates (should be even)" if args.length.odd?
  return {
    :points => args
  }
  end
}

SVGPlot::SVG_DEFAULTS = {
  :text => {:fill=>"black"},
  :line => {:stroke=>"black"},
  :rect => {:stroke=>"black"},
  :circle => {:stroke=>"black"},
  :ellipse => {:stroke=>"black"},
  :polygon => {:stroke=>"black"},
  :polyline => {:stroke=>"black"},
}

#TODO: move to documentation?
SVGPlot::SVG_TRANSFORM = [
  :matrix,    # expects an array of 6 elements
  :translate, #[tx, ty?]
  :scale,     #[sx, sy?]
  :rotate,    #[angle, (cx, cy)?]
  :skewX,     # angle
  :skewY,     # angle
]

SVGPlot::CSS_STYLE = [
  :fill,
  :stroke_width,
  :stroke,
  :fill_opacity,
  :stroke_opacity,
  :opacity,
]

