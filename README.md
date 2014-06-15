# Integration

[![Build Status](https://travis-ci.org/arrowcircle/integration.svg?branch=master)](https://travis-ci.org/arrowcircle/integration)
Numerical integration for Ruby, with a simple interface

## Installation

Add gem `integration` to your Gemfile:

	gem 'integration'

## Usage:

Integrate have only one method: `integrate`

Without GSL:

```
Integration.integrate(1, 2, {tolerance: 1e-10, method: :simpson}) { |x| x**2 }
=> 2.333333
```
With GSL (support for infinity bounds with GSL QAG adaptative integration):

```
func = ->(x) { (1/Math.sqrt(2 * Math::PI)) * Math.exp(-(x**2 / 2)) }

Integration.integrate(Integration::MInfinity, 0, {tolerance: 1e-10 }, &func)
=> 0.5

Integration.integrate(0, Integration::Infinity, {tolerance: 1e-10}, &func)
=> 0.5
```

## Available methods
Pure Ruby methods:

* Simpson (`:simpson`, default method)
* Rectangular (`:rectangular`)
* Trapezoidal (`:trapezoidal`)
* Adaptive quadrature (`:adaptive_quadrature`)
* Romberg (`:romberg`)
* Monte Carlo (`:monte_carlo`, bad results)

GSL methods:

* QNG (`:qng`)
* QAG (`:qag`)

## REQUIREMENTS:

Integration works only with Ruby 1.9+

Integration depends on GSL ( GNU Scientific Library ) for infinity bounds and faster algoritms support.

* For Mac OS X: `brew install gsl`
* For Ubuntu / Debian: `sudo apt-get install gsl`