# Checking the speed of different integraiton methods

require 'benchmark'
require 'integration'

iterations = 100
puts "Benchmarking with #{iterations} iterations"

# Benchmarking for function f(x) = x

f1 = lambda{|x| x}
puts "f(x) = x"
Benchmark.bm(25) do |bm|
  
  bm.report("Rectangle:") do
    iterations.times do
        Integration.integrate(0,1,{:method=>:rectangle},&f1)
    end
  end

  bm.report("Trapezoid:") do
    iterations.times do
        Integration.integrate(0,1,{:method=>:trapezoid},&f1)
    end
  end

  bm.report("Simpson:") do
    iterations.times do
        Integration.integrate(0,1,{:method=>:simpson},&f1)
    end
  end

  bm.report("Simpson 3/8:") do
    iterations.times do
        Integration.integrate(0,1,{:method=>:simpson3by8},&f1)
    end
  end

  bm.report("Boole:") do
    iterations.times do
        Integration.integrate(0,1,{:method=>:boole},&f1)
    end
  end

  bm.report("Open Trapezoid:") do  
    iterations.times do
        Integration.integrate(0,1,{:method=>:open_trapezoid},&f1)
    end
  end

  bm.report("Milne: ") do  
    iterations.times do
        Integration.integrate(0,1,{:method=>:milne},&f1)
    end
  end

  bm.report("Adaptive Quadrature:") do  
    iterations.times do
        Integration.integrate(0,1,{:method=>:adaptive_quadrature},&f1)
    end
  end

  bm.report("Gauss: ") do
    iterations.times do
        Integration.integrate(0,1,{:method=>:gauss},&f1)
    end
  end

  bm.report("Gauss Kronrod: ") do
    iterations.times do
        Integration.integrate(0,1,{:method=>:gauss_kronrod},&f1)
    end
  end

  bm.report("Romberg: ") do
      iterations.times do
        Integration.integrate(0,1,{:method=>:romberg},&f1)
    end
  end
end

# Benchmarking for function f(x) = f(x) = 49x^3 + 37cos(x)+ 9x

f1 = lambda{|x| 49*x**3 + 37*Math::cos(x) + 9*x}
puts "f(x) = 49x^3 + 37cos(x)+ 9x"
Benchmark.bm(25) do |bm|
  
  bm.report("Rectangle:") do
    iterations.times do
        Integration.integrate(0,1,{:method=>:rectangle},&f1)
    end
  end
  
  bm.report("Trapezoid:") do
    iterations.times do
        Integration.integrate(0,1,{:method=>:trapezoid},&f1)
    end
  end
  
  bm.report("Simpson:") do
    iterations.times do
        Integration.integrate(0,1,{:method=>:simpson},&f1)
    end
  end
  
  bm.report("Simpson 3/8:") do
    iterations.times do
        Integration.integrate(0,1,{:method=>:simpson3by8},&f1)
    end
  end
  
  bm.report("Boole:") do
    iterations.times do
        Integration.integrate(0,1,{:method=>:boole},&f1)
    end
  end
  
  bm.report("Open Trapezoid:") do  
    iterations.times do
        Integration.integrate(0,1,{:method=>:open_trapezoid},&f1)
    end
  end
  
  bm.report("Milne: ") do  
    iterations.times do
        Integration.integrate(0,1,{:method=>:milne},&f1)
    end
  end
  
  bm.report("Adaptive Quadrature:") do  
    iterations.times do
        Integration.integrate(0,1,{:method=>:adaptive_quadrature},&f1)
    end
  end
  
  bm.report("Gauss: ") do
    iterations.times do
        Integration.integrate(0,1,{:method=>:gauss},&f1)
    end
  end
  
  bm.report("Gauss Kronrod: ") do
    iterations.times do
        Integration.integrate(0,1,{:method=>:gauss_kronrod},&f1)
    end
  end
  
  bm.report("Romberg: ") do
      iterations.times do
        Integration.integrate(0,1,{:method=>:romberg},&f1)
    end
  end
end 