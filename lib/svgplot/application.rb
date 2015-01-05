module SVGPlot
  ##
  # Application object for running .svgplot files
  class Application
    def initialize(*args)
      @files = args.empty? ? Dir.glob(File.expand_path('*.svgplot')) : args
      fail('No input files') if @files.empty?
    end

    def run!
      @files.each do |file|
        output = file.sub(/\.svgplot/, '') + '.svg'
        File.open(output, 'w') do |fh|
          build file, fh
        end
      end
    end

    private

    def build(file, fh)
      SVGPlot::Plot.new({ width: '100%', height: '100%' }, fh) do
        begin
          instance_eval File.read(file), file
        rescue StandardError => e
          backtrace = e.backtrace.grep(Regexp.new(File.expand_path(file)))
          raise e.class, e.message, backtrace
        end
      end
    end
  end
end
