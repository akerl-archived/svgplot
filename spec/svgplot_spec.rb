require 'spec_helper'

describe SVGPlot do
  describe '#new' do
    it 'creates a Plot object' do
      expect(SVGPlot.new).to be_an_instance_of SVGPlot::Plot
    end
  end
end
