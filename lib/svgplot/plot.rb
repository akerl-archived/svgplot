module SVGPlot
  ##
  # Main Plot object, contains other tags
  class Plot < SVGPlot::SVGTagWithParent
    def initialize(params = {}, output = nil, &block)
      @defs = nil
      @defs_ids = {}

      params[:version] ||= '1.1'
      params[:xmlns] ||= 'http://www.w3.org/2000/svg'
      params[:"xmlns:xlink"] ||= 'http://www.w3.org/1999/xlink'
      super(self, 'svg', params, &block)

      @output = output || ''
      validate_output(@output) if output

      write(@output) if block
    end

    def add_def(id, child, if_exists = :skip, &block)
      @defs ||= SVGPlot::SVGTagWithParent.new(@img, 'defs')
      check_conflicts(id, if_exists) if @defs_ids.key?(id)

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
      validate_output(output)
      write_header(output)

      @children.unshift @defs if @defs
      super(output)
      @children.shift if @defs
    end

    private

    def check_conflicts(id, if_exists)
      case if_exists
      when :fail
        fail("Definition '#{id}' already exists")
      when :skip
        return @defs_ids[id]
      else
        @defs.children.reject! { |x| x.attributes[:id] == id }
      end
    end

    def validate_output(output)
      fail("Illegal output: #{output.inspect}") unless output.respond_to? :<<
    end

    # Writes file header
    def write_header(output)
      # rubocop:disable Metrics/LineLength
      output << <<-HEADER
<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
      HEADER
      # rubocop:enable Metrics/LineLength
    end
  end
end
