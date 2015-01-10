module SVGPlot
  ##
  # Tag object, represents a single SVG tag
  class Tag
    include Parsers::Tag
    include Transform
    include Defaults

    attr_reader :tag, :attributes, :children

    def initialize(tag, attributes = {}, &block)
      @tag = SVGPlot::Tag.parse_tag tag
      @attributes = parse_attributes attributes
      @children = []

      instance_exec(&block) if block
    end

    def raw(data)
      append_child Raw.new(@img, data)
    end

    def path(attributes = {}, &block)
      append_child Path.new(@img, attributes, &block)
    end

    def use(id, attributes = {})
      id = id.attributes[:id] if id.is_a? Tag
      attributes.merge!('xlink:href' => "##{id}")
      append_child ChildTag.new(@img, 'use', attributes)
    end

    def append_child(child)
      @children.push(child)
      child.defaults = defaults
      child
    end

    def to_s
      str = ''
      write(str)
      str
    end

    def write(output)
      output << "#{@tag}"
      @attributes.each { |attr, value| output << %( #{attr}="#{value}") }
      if @children.empty?
        output << '/>'
      else
        output << '>'
        @children.each { |c| c.write(output) }
        output << "</#{@tag}>"
      end
    end
  end

  ##
  # Child tag, used for tags within another tag
  class ChildTag < Tag
    attr_reader :img

    def initialize(img, tag, params = {}, &block)
      @img = img
      super(tag, params, &block)
    end

    def linear_gradient(id, attributes = {}, if_exists = :skip, &block)
      @img.add_def(id, LinearGradient.new(@img, attributes), if_exists, &block)
    end

    def radial_gradient(id, attributes = {}, if_exists = :skip, &block)
      @img.add_def(id, RadialGradient.new(@img, attributes), if_exists, &block)
    end
  end

  ##
  # Raw child, just prints data provided
  class Raw < ChildTag
    def initialize(img, data)
      @img = img
      @data = data
    end

    def write(output)
      output << @data.to_s
    end
  end
end
