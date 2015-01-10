module SVGPlot
  module Defaults
    def defaults
      @defaults ||= {}
    end

    def defaults=(new)
      @defaults = new
    end

    def with(defaults, &block)
      defaults = defaults
      instance_exec(&block)
      defaults = {}
    end
  end
end

