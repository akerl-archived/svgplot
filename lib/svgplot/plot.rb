module SVGPlot
  class SVGTag
    attr_reader :tag, :attributes, :children

    def initialize(tag, attributes={}, &block)
      @tag = validate_tag(tag)
      @attributes = validate_attributes(attributes)
      @children = []

      if block
        instance_exec &block
      end
    end

    ##
    # Provide methods for SVG transformations
    ##

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

    def validate_tag(tag)
      raise "#{tag} is not a valid tag" unless SVGPlot::SVG_ELEMENTS.include?(tag.to_sym)
      tag.to_sym
    end

    def validate_attributes(attributes)
      clean_attributes = {}
      transforms = {}
      styles = {}

      attributes.each do |attribute, value|
        if SVGPlot::SVG_TRANSFORM.include? attribute
          transforms[attribute] = value
        elsif SVGPlot::CSS_STYLE.include? attribute
          styles[attribute] = value
        else
          clean_attributes[validate_attribute(attribute)] = value
        end
      end

      #always prefer more verbose definition.
      unless transforms.empty?
        transforms.merge!(clean_attributes[:transform]) if clean_attributes[:transform]
        str = ""
        write_transforms(transforms, str)
        clean_attributes[validate_attribute(:transform)] = str
      end

      unless styles.empty?
        styles.merge!(clean_attributes[:style]) if clean_attributes[:style]
        clean_attributes[validate_attribute(:style)] = styles
      end
      clean_attributes
    end

    def validate_attribute(attribute)
      raise "#{@tag} does not support attribute #{attribute}" unless SVGPlot::SVG_STRUCTURE[@tag.to_sym][:attributes].include?(attribute.to_sym)
      attribute.to_sym
    end

    def write_styles(styles, output)
      styles.each do |attribute, value|
        attribute = attribute.to_s
        attribute.gsub!('_','-')
        output << "#{attribute}:#{value};"
      end
    end

    def write_transforms(transforms, output)
      transforms.each do |attribute, value|
        value = [value] unless value.is_a?(Array)
        output << "#{attribute.to_s}(#{value.join(',')}) "
      end
    end

    def write_points(points, output)
      points.each_with_index do |value, index|
        output << value.to_s
        output << ',' if index.even?
        output << ' ' if (index.odd? and (index != points.size-1))
      end
    end

    #special case for raw blocks.
    def raw(data)
      append_child SVGPlot::SVGRaw.new(@img, data)
    end

    #special case for path block
    def path(attributes = {}, &block)
      append_child SVGPlot::SVGPath.new(@img, attributes, &block)
    end

    #special case for use block
    def use(id, attributes = {})
      id = id.attributes[:id] if id.is_a? SVGPlot::SVGTag
      append_child SVGPlot::SVGTagWithParent.new(@img, "use", attributes.merge("xlink:href" => "##{id}"))
    end


    #special case for linearGradient
    def linearGradient(id, attributes={}, if_exists = :skip, &block)
      raise "image reference isn't set, cannot use 'defs' (and thus linearGradient) !" if @img.nil?
      @img.add_def(id, SVGPlot::SVGLinearGradient.new(@img, attributes), if_exists, &block)
    end

    
    #special case for radialGradient
    def radialGradient(id, attributes={}, if_exists = :skip, &block)
      raise "image reference isn't set, cannot use 'defs' (and thus radialGradient) !" if @img.nil?
      @img.add_def(id, SVGPlot::SVGRadialGradient.new(@img, attributes), if_exists, &block)
    end




    def spawn_child(tag, *args, &block)
      #expected args: nil, [hash], [...]
      parameters = {} if args.size == 0

      unless parameters #are empty
        parameters = args[0] if args[0].is_a? Hash
      end

      unless parameters #are set
        #try to find args expansion rule
        expansion = SVGPlot::SVG_EXPANSION[tag.to_sym]
        raise "Unnamed parameters for #{tag} are not allowed!" unless expansion
      
        if expansion.is_a? Array
          raise "Bad unnamed parameter count for #{tag}, expecting #{expansion.size} got #{if args.last.is_a? Hash then args.size-1 else args.size end}" unless (args.size == expansion.size and not args.last.is_a? Hash) or (args.size - 1 == expansion.size and args.last.is_a? Hash)
          parameters = Hash[expansion.zip(args)]
          if args.last.is_a? Hash
            parameters.merge! args.last
          end
        elsif expansion.is_a? Proc
          hash = args.pop if args.last.is_a? Hash
          parameters = expansion.call(args)
          parameters.merge! hash if hash
        else
          raise "Unexpected expansion mechanism: #{expansion.class}"
        end
      end

      # add default parameters if they are not overwritten
      merge_defaults().each do |key, value|
        parameters[key] = value unless parameters[key]
      end if @defaults

      append_child(SVGPlot::SVGTagWithParent.new(@img, tag, parameters, &block))
    end


    def append_child(child)
      @children.push(child)
      child.push_defaults(merge_defaults()) if @defaults
      child
    end


    def merge_defaults()
      result = {}
      return result if @defaults.empty?
      @defaults.each { |d| result.merge!(d) }
      result
    end

    
    def push_defaults(defaults)
      @defaults = [] unless @defaults
      @defaults.push(defaults)
    end

    
    def pop_defaults()
      @defaults.pop()
    end

    
    def with_style(style={}, &proc)
      push_defaults(style)
      # Call the block
      self.instance_exec(&proc)
      # Pop style again to revert changes
      pop_defaults()
    end

    
    def validate_child_name(name)
      #aliases the name (like, group instead of g)
      name = SVGPlot::SVG_ALIAS[name.to_sym] if SVGPlot::SVG_ALIAS[name.to_sym]

      #raises only if given name is an actual svg tag. In other case -- assumes user just mistyped.
      if SVGPlot::SVG_STRUCTURE[@tag.to_sym][:elements].include?(name.to_sym)
        name.to_sym
      elsif SVGPlot::SVG_ELEMENTS.include?(name.to_sym)
        raise "#{@tag} should not contain child #{name}" 
      end
    end


    def method_missing(meth, *args, &block)
      #if method is a setter or a getter, check valid attributes:
      check = /^(?<name>.*)(?<op>=|\?)$/.match(meth)
      if check
        raise "Passing a code block to setter or getter is not permited!" if block
        name = validate_attribute(check[:name].to_sym)
        if check[:op] == '?'
          @attributes[name]
        elsif check[:op] == '='
          raise "Setting an attribute with multiple values is not permited!" if args.size > 1
          @attributes[name] = args[0]
        end
      elsif child = validate_child_name(meth)
        spawn_child(child, *args, &block)
      else
        super
      end
    end
    

    def write(output)
      raise "Can not write to given output!" unless output.respond_to?(:<<)
      output << "<#{@tag.to_s}"
      @attributes.each do
        |attribute, value|
        output << " #{attribute.to_s}=\""
        if attribute == :style
          write_styles(value, output)
        elsif attribute == :points
          write_points(value, output)
        else
          output << "#{value.to_s}"
        end
        output << "\""
      end

      if @children.empty?
        output << "/>"
      else
        output << ">"
        @children.each { |c| c.write(output) }
        output << "</#{@tag.to_s}>"
      end  
    end

    def to_s
      str = ""
      write(str)
      return str
    end


  private

    def add_transform(type, params)
      attr_name = validate_attribute(:transform)
      @attributes[attr_name] = "" if @attributes[attr_name].nil?
      @attributes[attr_name] = @attributes[attr_name] + "#{type}(#{params})"
    end

  end
end


#Extension of SVGTag to provide a reference to the parent img (used for defs)
module SVGPlot
  class SVGTagWithParent < SVGPlot::SVGTag
    attr_reader :img

    def initialize(img, tag, params = {}, output=nil, &block)
      @img = img
      super(tag, params, &block)
    end
  end
end



#inherit from tag for basic functionality, control raw data using the write method
module SVGPlot
  class SVGRaw < SVGPlot::SVGTagWithParent

    def initialize(img, data)
      @img = img
      @data = data
    end

    def write(output)
      output << @data.to_s
    end
  end
end



module SVGPlot
  class Plot < SVGPlot::SVGTagWithParent
    def initialize(params = {}, output=nil, &block)
      @defs = nil
      @defs_ids = {}

      params[:"version"] = "1.1" unless params[:"version"]
      params[:"xmlns"] = "http://www.w3.org/2000/svg" unless params[:"xmlns"]
      params[:"xmlns:xlink"] = "http://www.w3.org/1999/xlink" unless params[:"xmlns:xlink"]
      super(self, "svg", params, &block)

      @output = (output or "")
      validate_output(@output) if output

      if block
        write(@output)
      end
    end

    def add_def(id, child, if_exists = :skip, &block)
      #init on the fly if needed
      @defs = SVGPlot::SVGTagWithParent.new(@img, "defs") if @defs.nil?

      #raise an error if id is already present and if_exists is :fail
      raise "Definition '#{id}' already exists" if @defs_ids.has_key? id and if_exists == :fail

      #return the existing element if id is already present and if_exists is :skip
      return @defs_ids[id] if if_exists == :skip and @defs_ids.has_key? id

      #search for the existing element
      if @defs_ids[id]
        old_idx = nil
        @defs.children.each_with_index { |c,i| if c.attributes[:id] == id then old_idx = i ; break end }
      end

      #force the id, append the child to definitions and call the given block to fill the group
      child.attributes[:id] = id
      @defs.append_child child
      @defs_ids[id] = child
      child.instance_exec block

      #remove the old element if present
      @defs.children.delete_at old_idx if old_idx

      return child
    end

    def def_group(id, if_exists = :skip, &block)
      g = SVGPlot::SVGTagWithParent.new(@img, "g", :id => id)
      return add_def(id, g, if_exists, &block)
    end

    #def text(x, y, text, style=DefaultStyles[:text])
    #  @output << %Q{<text x="#{x}" y="#{y}"}
    #  style = fix_style(default_style.merge(style))
    #  @output << %Q{ font-family="#{style.delete "font-family"}"} if style["font-family"]
    #  @output << %Q{ font-size="#{style.delete "font-size"}"} if style["font-size"]
    #  write_style style
    #  @output << ">"
    #  dy = 0      # First line should not be shifted
    #  text.each_line do |line|
    #    @output << %Q{<tspan x="#{x}" dy="#{dy}em">}
    #    dy = 1    # Next lines should be shifted
    #    @output << line.rstrip
    #    @output << "</tspan>"
    #  end
    #  @output << "</text>"
    #end


    def write(output)
      validate_output(output)
      write_header(output)

      @children.unshift @defs if @defs
      super(output)
      @children.shift if @defs
    end


    # how to define output << image ?
    #def <<(output)
    #  write(output)
    #end

    private

    def validate_output(output)
      raise "Illegal output object: #{output.inspect}" unless output.respond_to?(:<<)
    end

    # Writes file header
    def write_header(output)
      output << <<-HEADER
<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
      HEADER
    end
  end
end

#SVG Path element, with ruby methods to describe the path
class SVGPlot::SVGPath < SVGPlot::SVGTagWithParent
  def initialize(img = nil, attributes={}, &block)
    attributes.merge!(:d => "") unless attributes.has_key? :d
    super(img, "path", attributes)
  end

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
  # Draws a cubic Bezier curve from current pen point to dx,dy. x1,y1 and x2,y2
  # are start and end control points of the curve, controlling how it bends.
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
  # Draws a quadratic Bezier curve from current pen point to dx,dy. x1,y1 is the
  # control point controlling how the curve bends.
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
  # Draws a quadratic Bezier curve from current pen point to dx,dy. The control
  # point is assumed to be the same as the last control point used.
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
  # x-axis. It only seems to have an effect when rx and ry have different values.
  # The large-arc-flag doesn't seem to be used (can be either 0 or 1). Neither
  # value (0 or 1) changes the arc. 
  # The sweep-flag determines the direction to draw the arc in.
  #
  ##
  def arcTo(dx, dy, rx, ry, axis_rotation, large_arc_flag, sweep_flag)
    add_d("a#{rx},#{ry} #{axis_rotation} #{large_arc_flag},#{sweep_flag} #{dx},#{dy}")
  end


  def arcToA(dx, dy, rx, ry, axis_rotation, large_arc_flag, sweep_flag)
    add_d("A#{rx},#{ry} #{axis_rotation} #{large_arc_flag},#{sweep_flag} #{dx},#{dy}")
  end


  ##
  # close path command
  #
  # Closes the path by drawing a line from current point to first point.
  #
  ##
  def close
    add_d("Z")
  end


  private 
  def add_d(op)
    @attributes[:d] = @attributes[:d] + " " + op
  end
end

#SVG base gradient element, with ruby methods to describe the gradient
class SVGPlot::SVGGradient < SVGPlot::SVGTagWithParent

  def fill
    "url(##{@attributes[:id]})"
  end


  def stop(offset, color, opacity)
    append_child(SVGPlot::SVGTag.new("stop", "offset" => offset, "stop-color" => color, "stop-opacity" => opacity))
  end

end

#SVG linear gradient element
class SVGPlot::SVGLinearGradient < SVGPlot::SVGGradient

  def initialize(img, attributes={}, &block)
    super(img, "linearGradient", attributes, &block)
  end

end

#SVG radial gradient element
class SVGPlot::SVGRadialGradient < SVGPlot::SVGGradient

  def initialize(img, attributes={}, &block)
    super(img, "radialGradient", attributes, &block)
  end

end
