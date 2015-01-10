module SVGPlot
  ##
  # Tag object, represents a single SVG tag
  class Tag
    include Parsers::Tag
    include Transforms

    attr_reader :tag, :attributes, :children

    def initialize(tag, attributes = {}, &block)
      @img = 
      @tag = SVGPlot::Tag.parse_tag tag
      @attributes = parse_attributes attributes
      @children = []

      instance_exec(&block) if block
    end

    def parse_attributes(raw)
      clean = {
        transform: parse_transforms(raw.delete(:transform)),
        style: parse_styles(raw.delete(:style))
      }
      raw.delete(:data) { Hash.new }.each do |key, value|
        clean["data-#{key}".to_sym] = value
      end
      raw.each_key { |k| validate_attribute k }
      clean.reject(&:nil?).merge raw
    end
  end

  ##
  # Child tag, used for tags within another tag
  class ChildTag < Tag
    include AddGradient

    attr_reader :img

    def initialize(img, tag, params = {}, &block)
      @img = img
      super(tag, params, &block)
    end
  end

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
