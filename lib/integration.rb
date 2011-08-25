# Copyright (c) 2005  Beng (original code)
#               2011  clbustos
# 
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
# THE X CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
# OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# 
# Except as contained in this notice, the name of the Beng shall not
# be used in advertising or otherwise to promote the sale, use or other dealings
# in this Software without prior written authorization from Beng.

# Diverse integration methods
# Use Integration.integrate as wrapper to direct access to methods
# 
# Method API 
#

class Integration
  VERSION = '0.1.0'
  # Minus Infinity
  MInfinity=:minfinity
  # Infinity
  Infinity=:infinity
  class << self
    
    # Create a method 'has_<library>' on Module
    # which require a library and return true or false
    # according to success of failure 
    def create_has_library(library) #:nodoc:
      define_singleton_method("has_#{library}?") do
        cv="@@#{library}"
        if !class_variable_defined? cv
          begin 
            require library.to_s
            class_variable_set(cv, true)
          rescue LoadError
            class_variable_set(cv, false)
          end
        end
        class_variable_get(cv)
      end
    end
    
    # [t1] lower bound
    # [t2] higher bound
    # [n] number of subdivisions
    def get_nodes(t1,t2,n,mid_point=false,&f)
      d=(t2-t1) / n.to_f
      nodes=(0..n).map {|i|
        mid_point ? f.call(t1+i*d+d/2) : f.call(t1+i*d)
      }
      nodes.delete_at(nodes.size-1) if mid_point
      [nodes,d]
    end
    # Rectangle method
    # +n+ implies number of subdivisions
    # Source:
    #   * Ayres : Outline of calculus
    def rectangle(t1, t2, n, &f)
      nodes,d=get_nodes(t1,t2,n,true,&f)
      nodes.inject(0) {|ac,v| ac+v}*d
    end
    alias_method :midpoint, :rectangle
    # Trapezoid method
    # +n+ implies number of subdivisions
    def trapezoid(t1, t2, n, &f)
      nodes,d=get_nodes(t1,t2,n,false,&f)
      out=(d/2.0)*( nodes.first + 
          2*(nodes[1,nodes.size-2].inject(0) {|ac,v| ac+v} ) +
          nodes.last
      )
      return out
    end
    
    def simpson(t1, t2, n)
      n += 1 unless n % 2 == 0
      dt = (t2.to_f - t1) / n
      total_area = 0
      (0..n).each do |i|
        t = t1 + (dt * i)
        if i.zero? || (i == n)
          total_area += yield(t)
        elsif i % 2 == 0
          total_area += 2 * yield(t)
        else
          total_area += 4 * yield(t)
        end
      end
      #total_area *= dt / 3
      #return total_area
      total_area*dt/3.0
    end
  
    def adaptive_quadrature(a, b, tolerance)
      h = (b.to_f - a) / 2
      fa = yield(a)
      fc = yield(a + h)
      fb = yield(b)
      s = h * (fa + (4 * fc) + fb) / 3
      helper = Proc.new { |a, b, fa, fb, fc, h, s, level|
        if level < 1/tolerance.to_f
          fd = yield(a + (h / 2))
          fe = yield(a + (3 * (h / 2)))
          s1 = h * (fa + (4.0 * fd) + fc) / 6
          s2 = h * (fc + (4.0 * fe) + fb) / 6
          if ((s1 + s2) - s).abs <= tolerance
            s1 + s2
          else
            helper.call(a, a + h, fa, fc, fd, h / 2, s1, level + 1) +
            helper.call(a + h, b, fc, fb, fe, h / 2, s2, level + 1)
          end
        else
          raise "Integral did not converge"
        end
      }
      return helper.call(a, b, fa, fb, fc, h, s, 1)
    end
  
    def gauss(t1, t2, n)
      case n
        when 1
          z = [0.0]
          w = [2.0]
        when 2
          z = [-0.57735026919, 0.57735026919]
          w = [1.0, 1.0]
        when 3
          z = [-0.774596669241, 0.0, 0.774596669241]
          w = [0.555555555556, 0.888888888889, 0.555555555556]
        when 4
          z = [-0.861136311594, -0.339981043585, 0.339981043585, 0.861136311594]
          w = [0.347854845137, 0.652145154863, 0.652145154863, 0.347854845137]
        when 5
          z = [-0.906179845939, -0.538469310106, 0.0, 0.538469310106, 0.906179845939]
          w = [0.236926885056, 0.478628670499, 0.568888888889, 0.478628670499, 0.236926885056]
        when 6
          z = [-0.932469514203, -0.661209386466, -0.238619186083, 0.238619186083, 0.661209386466, 0.932469514203]
          w = [0.171324492379, 0.360761573048, 0.467913934573, 0.467913934573, 0.360761573048, 0.171324492379]
        when 7
          z = [-0.949107912343, -0.741531185599, -0.405845151377, 0.0, 0.405845151377, 0.741531185599, 0.949107912343]
          w = [0.129484966169, 0.279705391489, 0.381830050505, 0.417959183673, 0.381830050505, 0.279705391489, 0.129484966169]
        when 8
          z = [-0.960289856498, -0.796666477414, -0.525532409916, -0.183434642496, 0.183434642496, 0.525532409916, 0.796666477414, 0.960289856498]
          w = [0.10122853629, 0.222381034453, 0.313706645878, 0.362683783378, 0.362683783378, 0.313706645878, 0.222381034453, 0.10122853629]
        when 9
          z = [-0.968160239508, -0.836031107327, -0.613371432701, -0.324253423404, 0.0, 0.324253423404, 0.613371432701, 0.836031107327, 0.968160239508]
          w = [0.0812743883616, 0.180648160695, 0.260610696403, 0.31234707704, 0.330239355001, 0.31234707704, 0.260610696403, 0.180648160695, 0.0812743883616]
        when 10
          z = [-0.973906528517, -0.865063366689, -0.679409568299, -0.433395394129, -0.148874338982, 0.148874338982, 0.433395394129, 0.679409568299, 0.865063366689, 0.973906528517]
          w = [0.0666713443087, 0.149451349151, 0.219086362516, 0.26926671931, 0.295524224715, 0.295524224715, 0.26926671931, 0.219086362516, 0.149451349151, 0.0666713443087]
        else
          raise "Invalid number of spaced abscissas #{n}, should be 1-10"
      end
      sum = 0
      (0...n).each do |i|
        t = ((t1.to_f + t2) / 2) + (((t2 - t1) / 2) * z[i])
        sum += w[i] * yield(t)
      end
      return ((t2 - t1) / 2.0) * sum
    end
  
    def romberg(a, b, tolerance)
      # NOTE one-based arrays are used for convenience
      
      h = b.to_f - a
      m = 1
      close = 1
      r = [[], [], [], [], [], [], [], [], [], [], [], [], []];
      r[1][1] = (h / 2) * (yield(a) + yield(b))
      j = 1
      while j <= 11 && tolerance < close
        j += 1
        r[j][0] = 0
        h /= 2
        sum = 0
        (1..m).each do |k|
          sum += yield(a + (h * ((2 * k) - 1)))
        end
        m *= 2
        r[j][1] = r[j-1][1] / 2 + (h * sum)
        (1..j-1).each do |k|
          r[j][k+1] = r[j][k] + ((r[j][k] - r[j-1][k]) / ((4 ** k) - 1))
        end
        close = (r[j][j] - r[j-1][j-1])
      end
      return r[j][j]
    end
  
    def monte_carlo(t1, t2, n)
      width = (t2 - t1).to_f
      height = nil
      vals = []
      n.times do
        t = t1 + (rand() * width)
        ft = yield(t)
        height = ft if height.nil? || ft > height
        vals << ft
      end
      area_ratio = 0
      vals.each do |ft|
        area_ratio += (ft / height.to_f) / n.to_f
      end
      return (width * height) * area_ratio
    end
    def is_infinite?(v)
      v==Infinity or v==MInfinity
    end
    # Methods available on pure ruby
    RUBY_METHOD=[:rectangle,:trapezoid,:simpson, :adaptive_quadrature , :gauss, :romberg, :monte_carlo]
    # Methods available with Ruby/GSL library
    GSL_METHOD=[:qng, :qag]
    # Get the integral for a function +f+, with bounds +t1+ and
    # +t2+ given a hash of +options+. 
    # If Ruby/GSL is available, you could use +Integration::Minfinity+
    # and +Integration::Infinity+ as bounds. Method
    # Options are
    # [:tolerance]    Maximum difference between real and calculated integral.
    #                 Default: 1e-10
    # [:initial_step] Initial number of subdivitions
    # [:step]         Subdivitions increment on each iteration
    # [:method]       Integration method. 
    # Methods are
    # [:rectangle] for [:initial_step+:step*iteration] quadrilateral subdivisions
    # [:trapezoid] for [:initial_step+:step*iteration] trapezoid-al subdivisions
    # [:simpson]   for [:initial_step+:step*iteration] parabolic subdivisions
    # [:adaptive_quadrature] for recursive appoximations until error [tolerance]
    # [:gauss] [:initial_step+:step*iteration] weighted subdivisons using translated -1 -> +1 endpoints
    # [:romberg] extrapolation of recursion approximation until error < [tolerance]
    # [:monte_carlo] make [:initial_step+:step*iteration] random samples, and check for above/below curve
    # [:qng] GSL QNG non-adaptive Gauss-Kronrod integration
    # [:qag] GSL QAG adaptive integration, with support for infinite bounds
    def integrate(t1,t2,options=Hash.new, &f)
      inf_bounds=(is_infinite?(t1) or is_infinite?(t2))
      raise "No function passed" unless block_given?
      raise "Non-numeric bounds" unless ((t1.is_a? Numeric) and (t2.is_a? Numeric)) or inf_bounds
      if(inf_bounds)
        lower_bound=t1
        upper_bound=t2
        options[:method]=:qag if options[:method].nil?
      else 
        lower_bound = [t1, t2].min
        upper_bound = [t1, t2].max
      end
      def_method=(has_gsl?) ? :qag : :simpson
      default_opts={:tolerance=>1e-10, :initial_step=>16, :step=>16, :method=>def_method}
      options=default_opts.merge(options)
      if RUBY_METHOD.include? options[:method]
        raise "Ruby methods doesn't support infinity bounds" if inf_bounds
        integrate_ruby(lower_bound,upper_bound,options,&f)
      elsif GSL_METHOD.include? options[:method]
        integrate_gsl(lower_bound,upper_bound,options,&f)
      else
        raise "Unknown integration method \"#{options[:method]}\""
      end
    end
    def integrate_gsl(lower_bound,upper_bound,options,&f) 
      
      f = GSL::Function.alloc(&f)
      method=options[:method]
      tolerance=options[:tolerance]
     
      if(method==:qag)
        w = GSL::Integration::Workspace.alloc()
        if(is_infinite?(lower_bound) and  is_infinite?(upper_bound))        
          #puts "ambos"
          val=f.qagi([tolerance,0.0], 1000, w)  
        elsif is_infinite?(lower_bound)
          #puts "inferior #{upper_bound}"
          val=f.qagil(upper_bound, [tolerance, 0], w) 
        elsif is_infinite?(upper_bound)
          #puts "superior"
          val=f.qagiu(lower_bound, [tolerance, 0], w)
        else
          
          val=f.qag([lower_bound,upper_bound],[tolerance,0.0], GSL::Integration::GAUSS61, w)
        end
      elsif(method==:qng)
        val=f.qng([lower_bound, upper_bound], [tolerance, 0.0]) 
      else
        raise "Unknown integration method \"#{method}\""
      end
      val[0]
    end
    def integrate_ruby(lower_bound,upper_bound,options,&f)
      method=options[:method]
      tolerance=options[:tolerance]
      initial_step=options[:initial_step]
      step=options[:step]
      
      begin
        method_obj = Integration.method(method.to_s.downcase)
      rescue
        raise "Unknown integration method \"#{method}\""
      end
      current_step=initial_step

      if(method==:adaptive_quadrature or method==:romberg  or method==:gauss)
        if(method==:gauss)
          initial_step=10 if initial_step>10
          tolerance=initial_step
        end
        method_obj.call(lower_bound, upper_bound, tolerance, &f)
      else
        #puts "iniciando"
        value=method_obj.call(lower_bound, upper_bound, current_step, &f)
        previous=value+(tolerance*2)
        diffs=[]
        while((previous-value).abs > tolerance) do
          #puts("Valor:#{value}, paso:#{current_step}")
          #puts(current_step)
          diffs.push((previous-value).abs)
          #diffs.push value
          current_step+=step
          previous=value
          #puts "Llamando al metodo"
          
          value=method_obj.call(lower_bound, upper_bound, current_step, &f)
        end
        #p diffs
        
        value
      end
    end
  end
  create_has_library :gsl
end
