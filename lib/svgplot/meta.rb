##
# Define additional spec pieces outside the generated data
module SVGPlot
  ##
  # Aliases for common tags
  SVG_ALIAS = {
    group: :g,
    rectangle: :rect
  }.freeze

  ##
  # Generic lambda for adding points, used below
  POINT_LAMBDA = lambda do |args|
    if args.length.odd?
      raise ArgumentError 'Illegal number of coordinates (should be even)'
    end
    { points: args.each_slice(2).map { |x| x.join(',') }.join(' ') }
  end

  ##
  # Expansion definitions for unnamed args
  SVG_EXPANSION = {
    line: %i[x1 y1 x2 y2],
    circle: %i[cx cy r],
    image: %i[x y width height xlink:href],
    ellipse: %i[cx cy rx ry],
    text: %i[x y],
    rect: lambda do |args|
      unless [4, 5, 6].include? args.size
        raise ArgumentError 'Wrong unnamed argument count'
      end
      result = Hash[%i[x y width height].zip(args)]
      if args.size > 4
        result[:rx] = args[4]
        result[:ry] = args[5] || args[4]
      end
      result
    end,
    polygon: POINT_LAMBDA,
    polyline: POINT_LAMBDA
  }.freeze

  ##
  # Define processing for Expansion constants
  module Expansion
    def expand(tag, args)
      expansion = SVG_EXPANSION[tag.to_sym]
      raise("Unnamed parameters for #{tag} are not allowed!") unless expansion

      if expansion.is_a? Array
        parse_args(tag, expansion, args)
      elsif expansion.is_a? Proc
        expansion.call(args)
      else
        raise "Unexpected expansion mechanism: #{expansion.class}"
      end
    end
  end
end
