require 'spec_helper'

describe SVGPlot::Transform do
  let(:subject) do
    SVGPlot.new(width: 10, height: 10).text(1, 1) { 'test' }
  end

  it 'can translate on x plane' do
    subject.translate(1)
    expect(subject.attributes[:transform]).to eql 'translate(1, 0)'
  end

  it 'can translate on y and y planes' do
    subject.translate(1, 10)
    expect(subject.attributes[:transform]).to eql 'translate(1, 10)'
  end

  it 'can scale on x plane' do
    subject.scale(2)
    expect(subject.attributes[:transform]).to eql 'scale(2, 1)'
  end

  it 'can scale on y and y planes' do
    subject.scale(1, 10)
    expect(subject.attributes[:transform]).to eql 'scale(1, 10)'
  end

  it 'can rotate to an angle' do
    subject.rotate(10)
    expect(subject.attributes[:transform]).to eql 'rotate(10)'
  end

  it 'can rotate to an angle and offset' do
    subject.rotate(10, 5, 6)
    expect(subject.attributes[:transform]).to eql 'rotate(10, 5, 6)'
  end

  it 'can skew to an x angle' do
    subject.skew_x(10)
    expect(subject.attributes[:transform]).to eql 'skewX(10)'
  end

  it 'can skew to a y angle' do
    subject.skew_y(10)
    expect(subject.attributes[:transform]).to eql 'skewY(10)'
  end

  it 'can do a matrix transform' do
    subject.matrix(1, 2, 3, 4, 5, 6)
    expect(subject.attributes[:transform]).to eql 'matrix(1, 2, 3, 4, 5, 6)'
  end

  it 'validates matrix args' do
    expect { subject.matrix(1, 2) }.to raise_error RuntimeError
  end

  it 'can chain transforms' do
    subject.skew_x(5).scale(1, 2)
    expect(subject.attributes[:transform]).to eql 'skewX(5) scale(1, 2)'
  end
end
