# Checking the speed of different integraiton methods

require 'benchmark'
require 'integration'

# set the number of iterations
iterations = 100
puts "Benchmarking with #{iterations} iterations"

# put the function to be benchmarked here
func = lambda{|x| x}
for method in [:rectangle,:trapezoid,:simpson,:romberg, :adaptive_quadrature, :gauss, :gauss_kronrod, :simpson3by8, :boole, :open_trapezoid, :milne, :qng, :qag]
	Benchmark.bm(25) do |bm|
	  bm.report(method.to_s) do
	    iterations.times do
	        Integration.integrate(0,1,{:method=>method},&func)
	    end
	  end
	end
end
