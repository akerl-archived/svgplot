module SVGPlot
  class Tag
    def self.parse_args(tag, keys, values)
      if keys.size != values.size
        fail("Arg mismatch for #{tag}: wanted #{keys.size} got #{values.size}")
      end
      Hash[keys.zip(values)]
    end
  end
end

