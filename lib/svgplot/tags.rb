module SVGPlot
  ##
  # Main tag object, used for all SVG components
  class SVGTag
    include SVGPlot::Transform

    attr_reader :tag, :attributes, :children

    def initialize(tag, attributes = {}, &block)
      @tag = validate_tag(tag)
      @attributes = validate_attributes(attributes)
      @children = []

      instance_exec(&block) if block
    end

    def validate_tag(tag)
      return tag.to_sym if SVGPlot::SVG_ELEMENTS.include?(tag.to_sym)
      fail "#{tag} is not a valid tag"
    end

    def validate_attributes(attributes)
      clean_attributes = {}

      transforms = {}
      attributes.delete(:transform) { Hash.new }.each do |key, value|
        transforms[key] = value
      end
      unless transforms.empty?
        str = ''
        write_transforms(transforms, str)
        clean_attributes[validate_attribute(:transform)] = str
      end

      styles = {}
      attributes.delete(:style) { Hash.new }.each { |k, v| styles[k] = v }
      clean_attributes[validate_attribute(:style)] = styles unless styles.empty?

      attributes.delete(:data) { Hash.new }.each do |key, value|
        clean_attributes["data-#{key}".to_sym] = value
      end

      attributes.each do |key, value|
        clean_attributes[validate_attribute(key)] = value
      end

      clean_attributes
    end

    def validate_attribute(attribute)
      allowed = SVGPlot::SVG_STRUCTURE[@tag.to_sym][:attributes]
      return attribute.to_sym if allowed.include?(attribute.to_sym)
      fail "#{@tag} does not support attribute #{attribute}"
    end

    def write_styles(styles, output)
      styles.each do |attribute, value|
        attribute = attribute.to_s
        attribute.gsub!('_', '-')
        output << "#{attribute}:#{value};"
      end
    end

    def write_transforms(transforms, output)
      transforms.each do |attribute, value|
        value = [value] unless value.is_a?(Array)
        output << "#{attribute}(#{value.join(',')}) "
      end
    end

    def write_points(points, output)
      points.each_with_index do |value, index|
        output << value.to_s
        output << ',' if index.even?
        output << ' ' if index.odd? && index != points.size - 1
      end
    end

    def raw(data)
      append_child SVGPlot::SVGRaw.new(@img, data)
    end

    def path(attributes = {}, &block)
      append_child SVGPlot::SVGPath.new(@img, attributes, &block)
    end

    def use(id, attributes = {})
      id = id.attributes[:id] if id.is_a? SVGPlot::SVGTag
      append_child SVGPlot::SVGTagWithParent.new(
        @img,
        'use',
        attributes.merge('xlink:href' => "##{id}")
      )
    end

    def spawn_child(tag, *args, &block)
      parameters = {} if args.size == 0

      parameters = args[0] if args[0].is_a?(Hash) && parameters.nil?

      unless parameters
        expansion = SVGPlot::SVG_EXPANSION[tag.to_sym]
        fail("Unnamed parameters for #{tag} are not allowed!") unless expansion

        if expansion.is_a? Array
          arg_hash = args.last.is_a?(Hash) ? args.pop : {}
          unless args.size == expansion.size
            fail("Bad arg count for #{tag}: wanted #{expansion.size} got #{args.size}") # rubocop:disable Metrics/LineLength
          end
          parameters = Hash[expansion.zip(args)]
          parameters.merge! arg_hash
        elsif expansion.is_a? Proc
          hash = args.pop if args.last.is_a? Hash
          parameters = expansion.call(args)
          parameters.merge! hash if hash
        else
          fail "Unexpected expansion mechanism: #{expansion.class}"
        end
      end

      merge_defaults.each do |key, value|
        parameters[key] = value unless parameters[key]
      end if @defaults

      append_child(SVGPlot::SVGTagWithParent.new(@img, tag, parameters, &block))
    end

    def append_child(child)
      @children.push(child)
      child.push_defaults(merge_defaults) if @defaults
      child
    end

    def merge_defaults
      result = {}
      return result if @defaults.empty?
      @defaults.each { |d| result.merge!(d) }
      result
    end

    def push_defaults(defaults)
      @defaults ||= []
      @defaults.push(defaults)
    end

    def pop_defaults
      @defaults.pop
    end

    def with_style(style = {}, &proc)
      push_defaults(style)
      instance_exec(&proc)
      pop_defaults
    end

    def validate_child_name(name)
      name = SVGPlot::SVG_ALIAS[name.to_sym] if SVGPlot::SVG_ALIAS[name.to_sym]

      if SVGPlot::SVG_STRUCTURE[@tag.to_sym][:elements].include?(name.to_sym)
        name.to_sym
      elsif SVGPlot::SVG_ELEMENTS.include?(name.to_sym)
        fail "#{@tag} should not contain child #{name}"
      end
    end

    def method_missing(meth, *args, &block)
      check = /^(?<name>.*)(?<op>=|\?)$/.match(meth)
      child_name = validate_child_name(meth)
      if check
        fail('Passing a block to setter or getter is not permitted') if block
        name = validate_attribute(check[:name].to_sym)
        if check[:op] == '?'
          @attributes[name]
        elsif check[:op] == '='
          if args.size > 1
            fail('Setting an attribute with multiple values is not permitted!')
          end
          @attributes[name] = args[0]
        end
      elsif child_name
        spawn_child(child_name, *args, &block)
      else
        super
      end
    end

    def write(output)
      fail('Can not write to given output!') unless output.respond_to? :<<
      output << "<#{@tag}"
      @attributes.each do
        |attribute, value|
        output << " #{attribute}=\""
        if attribute == :style
          write_styles(value, output)
        elsif attribute == :points
          write_points(value, output)
        else
          output << value.to_s
        end
        output << '"'
      end

      if @children.empty?
        output << '/>'
      else
        output << '>'
        @children.each { |c| c.write(output) }
        output << "</#{@tag}>"
      end
    end

    def to_s
      str = ''
      write(str)
      str
    end

    private

    def add_transform(type, params)
      attr_name = validate_attribute(:transform)
      @attributes[attr_name] = '' if @attributes[attr_name].nil?
      @attributes[attr_name] = @attributes[attr_name] + "#{type}(#{params})"
    end
  end

  # Extension of SVGTag to provide a reference to the parent img
  class SVGTagWithParent < SVGPlot::SVGTag
    attr_reader :img

    def initialize(img, tag, params = {}, &block)
      @img = img
      super(tag, params, &block)
    end
  end
end
