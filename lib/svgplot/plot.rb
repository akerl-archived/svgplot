module SVGPlot
  ##
  # Main Plot object
  class Plot < ChildTag
    DEFAULTS = {
      version: 1.1,
      xmlns: 'http://www.w3.org/2000/svg',
      :'xmlns:xlink' => 'http://www.w3.org/1999/xlink' # rubocop:disable Style/HashSyntax, Metrics/LineLength, Lint/UnneededDisable
    }.freeze

    def initialize(params = {}, output = nil, &block)
      params = DEFAULTS.dup.merge params
      super(self, 'svg', params, &block)
      @output = output || ''
      write(@output) if block
    end

    def add_def(id, child, if_exists = :skip, &block)
      @defs ||= ChildTag.new(@img, 'defs')
      @defs_ids ||= {}
      old_id = check_conflicts(id, if_exists) if @defs_ids.key? id
      return old_id if old_id

      child.attributes[:id] = id
      @defs.append_child child
      @defs_ids[id] = child
      child.instance_exec block if block

      child
    end

    def def_group(id, if_exists = :skip, &block)
      g = SVGPlot::SVGTagWithParent.new(@img, 'g', id: id)
      add_def(id, g, if_exists, &block)
    end

    def write(output)
      raise("Illegal output: #{@output.inspect}") unless @output.respond_to? :<<
      output << header
      @children.unshift @defs if @defs
      super(output)
      @children.shift if @defs
    end

    private

    def check_conflicts(id, if_exists)
      case if_exists
      when :fail
        raise("Definition '#{id}' already exists")
      when :skip
        @defs_ids[id]
      else
        @defs.children.reject! { |x| x.attributes[:id] == id }
        nil
      end
    end

    def header
      [
        %(<?xml version="1.0" standalone="no"?>\n),
        %(<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" ),
        %("http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">)
      ].join
    end
  end
end
