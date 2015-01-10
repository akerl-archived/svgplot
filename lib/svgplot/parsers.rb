module SVGPlot
  module Parsers
    module Tag
      private

      def parse_tag(tag)
        return tag.to_sym if SVGPlot::SVG_ELEMENTS.include?(tag.to_sym)
        fail "#{tag} is not a valid tag"
      end

      def parse_args(tag, keys, values)
        if keys.size != values.size
         fail("Arg mismatch for #{tag}: wanted #{keys.size} got #{values.size}")
        end
        Hash[keys.zip(values)]
      end

      def valid_attribute?(attribute)
        allowed = SVGPlot::SVG_STRUCTURE[@tag.to_sym][:attributes]
        return attribute.to_sym if allowed.include?(attribute.to_sym)
        fail "#{@tag} does not support attribute #{attribute}"
      end

      def parse_transforms(transforms)
        return nil unless transforms && valid_attribute?(:transform)
        transforms.each_with_object('') do |(attr, value), str|
          str << "#{attr}(#{value.is_a?(Array) ? value.join(',') : value }) "
        end
      end

      def parse_styles(styles)
        return nil unless styles && valid_attribute?(:styles)
        styles.each_with_object('') { |(k, v), str| str << "#{k}:#{v};" }
      end 
    end
  end
end
