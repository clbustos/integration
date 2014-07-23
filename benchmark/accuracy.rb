# Comparing the accuracy of different integraiton methods

require 'integration'
require 'text-table'

f1 = lambda{|x| x**2}
actual_result = 1/3.0
puts "f(x) = x^2 on (0,1)"

table = Text::Table.new
table.head = ['Method','Result','Actual Result','Error','Accuracy']
#adaptive quadrature and romberg removed as they are returning nil values and are failing tests also
for method in [:rectangle,:trapezoid,:simpson, :gauss, :gauss_kronrod, :simpson3by8, :boole, :open_trapezoid, :milne]
  result = Integration.integrate(0,1,{:method=>method},&f1)
  if result == nil
    puts method
  else
  error = (actual_result-result).abs
  table.rows << [method,result,actual_result,error,100 * error/actual_result.to_f]
  end
  
end
puts table.to_s

