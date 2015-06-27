module SVGPlot
  module Parsers
    ##
    # Add parsing methods for various attributes
    module Tag
      private

      def parse_tag(tag)
        return tag.to_sym if SVGPlot::SVG_ELEMENTS.include?(tag.to_sym)
        fail "#{tag} is not a valid tag"
      end

      def parse_args(tag, keys, values)
        if keys.size != values.size
          fail("Arg mismatch for #{tag}: got #{values.size}, not #{keys.size}")
        end
        Hash[keys.zip(values)]
      end

      def valid_attribute?(attribute)
        allowed = SVGPlot::SVG_STRUCTURE[@tag.to_sym][:attributes]
        return true if allowed.include?(attribute.to_sym)
        false
      end

      def validate_attribute(attribute)
        return attribute.to_sym if valid_attribute? attribute
        fail "#{@tag} does not support attribute #{attribute}"
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
        clean.reject { |_, v| v.nil? }.merge raw
      end

      def parse_transforms(transforms)
        return nil unless transforms && valid_attribute?(:transform)
        transforms.each_with_object('') do |(attr, value), str|
          str << "#{attr}(#{value.is_a?(Array) ? value.join(',') : value}) "
        end
      end

      def parse_styles(styles)
        return nil unless styles && valid_attribute?(:style)
        styles.each_with_object('') { |(k, v), str| str << "#{k}:#{v};" }
      end

      def parse_method_name(method)
        check = /^(?<name>.*)(?<op>=|\?)$/.match(method)
        return check if check && valid_attribute?(check[:name])
      end

      def parse_method_op(op, attr, args, &block)
        fail('Invalid attribute name') unless valid_attribute? attr
        fail('Passing a block to setter or getter is not permitted') if block
        return @attributes[attr] if op == '?'
        return @attributes[attr] = args.first if args.size == 1
        fail('Setting an attribute with multiple values is not permitted!')
      end

      def parse_child_name(name)
        name = SVG_ALIAS[name.to_sym] if SVG_ALIAS[name.to_sym]

        if SVG_STRUCTURE[@tag.to_sym][:elements].include?(name.to_sym)
          return name.to_sym
        elsif SVG_ELEMENTS.include?(name.to_sym)
          fail "#{@tag} should not contain child #{name}"
        end
        nil
      end
    end
  end
end
