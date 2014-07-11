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

