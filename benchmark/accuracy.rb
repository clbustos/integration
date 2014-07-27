# Comparing the accuracy of different integraiton methods
# text table is required to display the results in a nice table
require 'integration'
require 'text-table'

# put the funtion you want to benchmark here
func = lambda{|x| x}
#put the actual result of the integration here
actual_result = 5/2.0 + 2* Math::sin(1)

table = Text::Table.new
table.head = ['Method','Result','Actual Result','Error','Accuracy']

for method in [:rectangle,:trapezoid,:simpson,:romberg,:adaptive_quadrature, :gauss, :gauss_kronrod, :simpson3by8, :boole, :open_trapezoid, :milne,:qng, :qag]
  result = Integration.integrate(0,1,{:method=>method},&func)
  if result == nil
    puts method
  else
  error = (actual_result-result).abs
  table.rows << [method,result,actual_result,error,100*(1-error/actual_result.to_f)]
  end
end
puts table.to_s

