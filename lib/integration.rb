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
    # Rectangle method
    # +n+ implies number of subdivisions
    # Source:
    #   * Ayres : Outline of calculus
    def rectangle(t1, t2, n, &f)
      d=(t2-t1) / n.to_f
      n.times.inject(0) {|ac,i| 
        ac+f[t1+d*(i+0.5)]
      }*d
    end
    alias_method :midpoint, :rectangle
    # Trapezoid method
    # +n+ implies number of subdivisions
    # Source:
    #   * Ayres : Outline of calculus
    def trapezoid(t1, t2, n, &f)
      d=(t2-t1) / n.to_f
      (d/2.0)*(f[t1]+
      2*(1..(n-1)).inject(0){|ac,i| 
      ac+f[t1+d*i]
      }+f[t2])
    end
    # Simpson's rule
    # +n+ implies number of subdivisions
    # Source:
    #   * Ayres : Outline of calculus
    def simpson(t1, t2, n, &f)
      n += 1 unless n % 2 == 0
      d=(t2-t1) / n.to_f      
      out= (d / 3.0)*(f[t1.to_f].to_f+
      ((1..(n-1)).inject(0) {|ac,i|
        ac+((i%2==0) ? 2 : 4)*f[t1+d*i]  
      })+f[t2.to_f].to_f)
      out
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

    def gauss_kronrod()
      #g7k15
      n15 = [0.0, 0.20778495500789848, 0.4058451513773972, 0.5860872354676911, 0.7415311855993945, 0.8648644233597691, 0.9491079123427585, 0.9914553711208126, -0.20778495500789848, -0.4058451513773972, -0.5860872354676911, -0.7415311855993945, -0.8648644233597691, -0.9491079123427585, -0.9914553711208126]
      w15 = [0.20948214108472782, 0.20443294007529889, 0.19035057806478542, 0.1690047266392679, 0.14065325971552592, 0.10479001032225019, 0.06309209262997856, 0.022935322010529224, 0.20443294007529889, 0.19035057806478542, 0.1690047266392679, 0.14065325971552592, 0.10479001032225019, 0.06309209262997856, 0.022935322010529224]

      #g10k21
      n21 = [0.0, 0.14887433898163122, 0.2943928627014602, 0.4333953941292472, 0.5627571346686047, 0.6794095682990244, 0.7808177265864169, 0.8650633666889845, 0.9301574913557082, 0.9739065285171717, 0.9956571630258081, -0.14887433898163122, -0.2943928627014602, -0.4333953941292472, -0.5627571346686047, -0.6794095682990244, -0.7808177265864169, -0.8650633666889845, -0.9301574913557082, -0.9739065285171717, -0.9956571630258081]
      w21 = [0.1494455540029169, 0.14773910490133849, 0.14277593857706009, 0.13470921731147334, 0.12349197626206584, 0.10938715880229764, 0.0931254545836976, 0.07503967481091996, 0.054755896574351995, 0.032558162307964725, 0.011694638867371874, 0.14773910490133849, 0.14277593857706009, 0.13470921731147334, 0.12349197626206584, 0.10938715880229764, 0.0931254545836976, 0.07503967481091996, 0.054755896574351995, 0.032558162307964725, 0.011694638867371874]

      #g15k31
      n31 = [0.0, 0.1011420669187175, 0.20119409399743451, 0.29918000715316884, 0.3941513470775634, 0.4850818636402397, 0.5709721726085388, 0.650996741297417, 0.7244177313601701, 0.790418501442466, 0.8482065834104272, 0.8972645323440819, 0.937273392400706, 0.9677390756791391, 0.9879925180204854, 0.9980022986933971, -0.1011420669187175, -0.20119409399743451, -0.29918000715316884, -0.3941513470775634, -0.4850818636402397, -0.5709721726085388, -0.650996741297417, -0.7244177313601701, -0.790418501442466, -0.8482065834104272, -0.8972645323440819, -0.937273392400706, -0.9677390756791391, -0.9879925180204854, -0.9980022986933971]
      w31 = [0.10133000701479154, 0.10076984552387559, 0.09917359872179196, 0.09664272698362368, 0.09312659817082532, 0.08856444305621176, 0.08308050282313302, 0.07684968075772038, 0.06985412131872826, 0.06200956780067064, 0.05348152469092809, 0.04458975132476488, 0.03534636079137585, 0.02546084732671532, 0.015007947329316122, 0.005377479872923349, 0.10076984552387559, 0.09917359872179196, 0.09664272698362368, 0.09312659817082532, 0.08856444305621176, 0.08308050282313302, 0.07684968075772038, 0.06985412131872826, 0.06200956780067064, 0.05348152469092809, 0.04458975132476488, 0.03534636079137585, 0.02546084732671532, 0.015007947329316122, 0.005377479872923349]

      #g20k41
      n41 = [0.0, 0.07652652113349734, 0.15260546524092267, 0.22778585114164507, 0.301627868114913, 0.37370608871541955, 0.4435931752387251, 0.5108670019508271, 0.5751404468197103, 0.636053680726515, 0.6932376563347514, 0.7463319064601508, 0.7950414288375512, 0.8391169718222188, 0.878276811252282, 0.912234428251326, 0.9408226338317548, 0.9639719272779138, 0.9815078774502503, 0.9931285991850949, 0.9988590315882777, -0.07652652113349734, -0.15260546524092267, -0.22778585114164507, -0.301627868114913, -0.37370608871541955, -0.4435931752387251, -0.5108670019508271, -0.5751404468197103, -0.636053680726515, -0.6932376563347514, -0.7463319064601508, -0.7950414288375512, -0.8391169718222188, -0.878276811252282, -0.912234428251326, -0.9408226338317548, -0.9639719272779138, -0.9815078774502503, -0.9931285991850949, -0.9988590315882777]
      w41 = [0.07660071191799965, 0.07637786767208074, 0.07570449768455667, 0.07458287540049918, 0.07303069033278667, 0.07105442355344407, 0.06864867292852161, 0.06583459713361842, 0.06265323755478117, 0.05911140088063957, 0.05519510534828599, 0.05094457392372869, 0.04643482186749767, 0.041668873327973685, 0.036600169758200796, 0.0312873067770328, 0.02588213360495116, 0.020388373461266523, 0.014626169256971253, 0.008600269855642943, 0.0030735837185205317, 0.07637786767208074, 0.07570449768455667, 0.07458287540049918, 0.07303069033278667, 0.07105442355344407, 0.06864867292852161, 0.06583459713361842, 0.06265323755478117, 0.05911140088063957, 0.05519510534828599, 0.05094457392372869, 0.04643482186749767, 0.041668873327973685, 0.036600169758200796, 0.0312873067770328, 0.02588213360495116, 0.020388373461266523, 0.014626169256971253, 0.008600269855642943, 0.0030735837185205317]

      #g30k61
      n61 = [0.0, 0.0514718425553177, 0.10280693796673702, 0.15386991360858354, 0.20452511668230988, 0.25463692616788985, 0.30407320227362505, 0.3527047255308781, 0.4004012548303944, 0.44703376953808915, 0.49248046786177857, 0.5366241481420199, 0.5793452358263617, 0.6205261829892429, 0.6600610641266269, 0.6978504947933158, 0.7337900624532268, 0.7677774321048262, 0.799727835821839, 0.8295657623827684, 0.8572052335460612, 0.8825605357920527, 0.9055733076999078, 0.9262000474292743, 0.94437444474856, 0.9600218649683075, 0.9731163225011262, 0.9836681232797472, 0.9916309968704046, 0.9968934840746495, 0.9994844100504906, -0.0514718425553177, -0.10280693796673702, -0.15386991360858354, -0.20452511668230988, -0.25463692616788985, -0.30407320227362505, -0.3527047255308781, -0.4004012548303944, -0.44703376953808915, -0.49248046786177857, -0.5366241481420199, -0.5793452358263617, -0.6205261829892429, -0.6600610641266269, -0.6978504947933158, -0.7337900624532268, -0.7677774321048262, -0.799727835821839, -0.8295657623827684, -0.8572052335460612, -0.8825605357920527, -0.9055733076999078, -0.9262000474292743, -0.94437444474856, -0.9600218649683075, -0.9731163225011262, -0.9836681232797472, -0.9916309968704046, -0.9968934840746495, -0.9994844100504906]
      w61 = [0.05149472942945157, 0.05142612853745902, 0.051221547849258774, 0.05088179589874961, 0.05040592140278235, 0.04979568342707421, 0.04905543455502978, 0.04818586175708713, 0.04718554656929915, 0.04605923827100699, 0.04481480013316266, 0.04345253970135607, 0.041969810215164244, 0.040374538951535956, 0.038678945624727595, 0.03688236465182123, 0.034979338028060025, 0.03298144705748372, 0.030907257562387762, 0.02875404876504129, 0.0265099548823331, 0.0241911620780806, 0.021828035821609193, 0.019414141193942382, 0.01692088918905327, 0.014369729507045804, 0.011823015253496341, 0.009273279659517764, 0.0066307039159312926, 0.003890461127099884, 0.0013890136986770077, 0.05142612853745902, 0.051221547849258774, 0.05088179589874961, 0.05040592140278235, 0.04979568342707421, 0.04905543455502978, 0.04818586175708713, 0.04718554656929915, 0.04605923827100699, 0.04481480013316266, 0.04345253970135607, 0.041969810215164244, 0.040374538951535956, 0.038678945624727595, 0.03688236465182123, 0.034979338028060025, 0.03298144705748372, 0.030907257562387762, 0.02875404876504129, 0.0265099548823331, 0.0241911620780806, 0.021828035821609193, 0.019414141193942382, 0.01692088918905327, 0.014369729507045804, 0.011823015253496341, 0.009273279659517764, 0.0066307039159312926, 0.003890461127099884, 0.0013890136986770077]


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
