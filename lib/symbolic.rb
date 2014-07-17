$LOAD_PATH<<'.'
require 'java'
require '/home/rajat/jscience.jar'
java_import Java::OrgJscienceMathematicsFunction.Variable
java_import Java::OrgJscienceMathematicsFunction.Polynomial
import 'org.jscience.mathematics.number.Real'


class Var #variable and symbol are already class in ruby
  def initialize(sym)
    @sym = sym
    @var = Variable::Local.new(@sym)
  end

  def show_symbol
  	puts @sym
  end
end

class Polynomial
	def initialize(poly, vars)
		@poly = poly # Write parser? or ask the user to write full poly?
		

	end
#java_import Java::OrgJscienceMathematicsFunction.Variable
#java_import Java::OrgJscienceMathematicsFunction.Polynomial
#import 'org.jscience.mathematics.number.Real'
 
##declaring 'x' and 'y' as symbols
#varX = Variable::Local.new('x')
#varY = Variable::Local.new('y')
 
#creating a polynomial x
# x = Polynomial.valueOf(Real::ONE,varX)
#creating a polynomial fx = 1(x^5) + 6(x^2)
#fx = x.pow(5).plus(x.pow(2).times(Real.valueOf(6)))
 
#integrating with respect to variable 'x'
#puts fx.integrate(varX)
#integrating with respect to variable 'y'
#puts fx.integrate(varY)

#def polynomial(&block)
 # varX = Variable::Local.new('x')
 # x = Polynomial.valueOf(Real::ONE,varX)
  yield x 
#end
 
# Creating a polynomial fx = 1(x^5) + 6(x^2).
#fx = polynomial do |x|
#  x.pow(5).plus(x.pow(2).times(Real.valueOf(6)))
# end
# Integrating with respect to variable 'x'.
#puts fx.integrate(varX)  