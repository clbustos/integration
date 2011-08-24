= integration

* http://github.com/clbustos/integration

== DESCRIPTION:

Numerical integration for Ruby, with a simple interface

== FEATURES/PROBLEMS:

* Use only one method: Integration.integrate
* Rectangular, Trapezoidal, Simpson, Adaptive quadrature, Monte Carlo and Romberg integration methods available on pure Ruby. 
* If available, uses Ruby/GSL QNG non-adaptive Gauss-Kronrod integration and QAG adaptive integration, with support for Infinity+ and Infinity- 


== SYNOPSIS:

  Integration.integrate(1,2,{:tolerance=>1e-10,:method=>:simpson}) {|x| x**2} => 2.333333
  
  # Support for infinity bounds with GSL QAG adaptative integration
  
  normal_pdf=lambda {|x| (1/Math.sqrt(2*Math::PI))*Math.exp(-(x**2/2))}
  Integration.integrate(Integration::MInfinity, 0 , {:tolerance=>1e-10}, &normal_pdf) => 0.5
  Integration.integrate(0, Integration::Infinity , {:tolerance=>1e-10}, &normal_pdf) => 0.5
  
== REQUIREMENTS:

* Ruby/GSL, for better performance and support for infinite bounds

== INSTALL:

  gem install integration
  
== LICENSE:

    Copyright (c) 2005  Beng
                  2011  clbustos
    
    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the "Software"),
    to deal in the Software without restriction, including without limitation
    the rights to use, copy, modify, merge, publish, distribute, sublicense,
    and/or sell copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
    THE DEVELOPERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
    OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
    
    Except as contained in this notice, the name of the Beng shall not
    be used in advertising or otherwise to promote the sale, use or other dealings
    in this Software without prior written authorization from Beng.

