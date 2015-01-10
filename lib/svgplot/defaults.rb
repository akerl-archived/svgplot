module SVGPlot
  ##
  # Adds default attributes helpers for Tags
  module Defaults
    attr_writer :defaults

    def defaults
      @defaults ||= {}
    end

    def with(defaults, &block)
      @defaults = defaults
      instance_exec(&block)
      @defaults = {}
    end
  end
end
