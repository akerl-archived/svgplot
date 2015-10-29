svgplot
=========

[![Gem Version](https://img.shields.io/gem/v/svgplot.svg)](https://rubygems.org/gems/svgplot)
[![Dependency Status](https://img.shields.io/gemnasium/akerl/svgplot.svg)](https://gemnasium.com/akerl/svgplot)
[![Build Status](https://img.shields.io/circleci/project/akerl/svgplot.svg)](https://circleci.com/gh/akerl/svgplot)
[![Coverage Status](https://img.shields.io/codecov/c/github/akerl/svgplot.svg)](https://codecov.io/github/akerl/svgplot)
[![Code Quality](https://img.shields.io/codacy/a4ad68dc9c4940b58f9b78ec1996f533.svg)](https://www.codacy.com/app/akerl/svgplot)
[![MIT Licensed](https://img.shields.io/badge/license-MIT-green.svg)](https://tldrlegal.com/license/mit-license)

SVG creation library forked from [xytis's Rasem fork](https://github.com/xytis/rasem).

## Usage

Create an SVG object by initializing it with a size:

```
plot = SVGPlot.new(width: 100, height: 100)
```

### Transformations

To do an SVG transform on an object, just call the desired transform method on it:

```
plot = SVGPlot.new(width: 100, height: 100)
plot.text(1, 1) { 'foobar' }.translate(5, 5)
```

You can call transforms after the fact as well:

```
plot = SVGPlot.new(width: 100, height: 100)
text = plot.text(1, 1) { 'foobar' }
text.scale(2)
```

The list of available transforms:

* translate(x, y = 0)
* scale(x, y = 1)
* rotate(angle, x = nil, y = nil)
* skew_x(angle)
* skew_y(angle)
* matrix(a, b, c, d, e, f)

## Installation

    gem install svgplot

## License

svgplot is released under the MIT License. See the bundled LICENSE file for details.

