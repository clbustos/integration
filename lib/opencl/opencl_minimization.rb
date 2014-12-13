require 'ffi'

module OpenCLMinimization extend FFI::Library

  MAX_ITERATIONS_DEFAULT = 100000
  EPSILON_DEFAULT        = 0.00001
  GOLDEN_DEFAULT         = 0.3819660
  SQRT_EPSILON_DEFAULT   = 0.00001
  PATH_TO_KERNEL = File.expand_path(File.dirname(__FILE__))

  ffi_lib "#{File.expand_path(File.dirname(__FILE__))}/cl.so"

  # attack with the opencl_minimize of min_host.c
  attach_function 'opencl_minimize', [:int, :pointer, :pointer, :pointer, :int, :string, :string,
                                     :string, :pointer, :pointer, :int, :int, :float, :float, :float, :string], :void

  # Classic GodlSectionMinimizer minimization method.  
  # Basic minimization algorithm. Slow, but robust.
  # See Unidimensional for methods.
  # == Usage
  #  n              = 3
  #  start_point    = [1, 3, 5]
  #  expected_point = [1.5, 3.5, 5.5]
  #  end_point      = [3, 5, 7]
  #  f              = "pow((x-2)*(x-4)*(x-6), 2)+1"
  #  min = OpenCLMinimization::GodlSectionMinimizer.new(n, start_point, expected_point, end_point, f)
  #  min.minimize
  #  min.x_minimum
  #  min.f_minimum   
  #
  class GodlSectionMinimizer
    attr_reader :x_minimum
    attr_reader :f_minimum

    attr_writer :max_iterations
    attr_writer :epsilon
    attr_writer :golden

    # == Parameters:
    # * <tt>n</tt>: Number of Jobs
    # * <tt>start_point</tt>: Lower possible value
    # * <tt>expected_point</tt>: Initial point
    # * <tt>end_point</tt>: Higher possible value
    # * <tt>f</tt>: Original function string
    #
    def initialize(n, start_point, expected_point, end_point, f)
      @n              = n
      @start_point    = start_point
      @expected_point = expected_point
      @end_point      = end_point
      @f              = f
      @max_iterations = MAX_ITERATIONS_DEFAULT
      @epsilon        = EPSILON_DEFAULT
      @golden         = GOLDEN_DEFAULT
      @sqrt_epsilon   = SQRT_EPSILON_DEFAULT
    end

    def minimize
      # create Buffers for inputs and outputs
      start_buffer    = FFI::Buffer.alloc_inout(:pointer, @n)
      expected_buffer = FFI::Buffer.alloc_inout(:pointer, @n)
      end_buffer      = FFI::Buffer.alloc_inout(:pointer, @n)
      x_buffer        = FFI::Buffer.alloc_inout(:pointer, @n)
      f_buffer        = FFI::Buffer.alloc_inout(:pointer, @n)

      # set inputs
      start_buffer.write_array_of_float(@start_point)
      expected_buffer.write_array_of_float(@expected_point)
      end_buffer.write_array_of_float(@end_point)

      # call minimizer
      OpenCLMinimization::opencl_minimize(@n, start_buffer, expected_buffer, end_buffer, 0, @f, "", "", x_buffer,
                                          f_buffer, 0, @max_iterations, @epsilon, @golden, @sqrt_epsilon, PATH_TO_KERNEL)

      @x_minimum = Array.new(@n)
      @f_minimum = Array.new(@n)
      # read results
      @x_minimum = x_buffer.read_array_of_float(@n)
      @f_minimum = f_buffer.read_array_of_float(@n)
    end
    end

  # Classic Newton-Raphson minimization method.  
  # Requires first and second derivative
  # == Usage
  #  n              = 3
  #  expected_point = [1, 100, 1000]
  #  f              = "(x-3)*(x-3)+5"
  #  fd             = "2*(x-3)"
  #  fdd            = "2"
  #  min = OpenCLMinimization::NewtonRampsonMinimizer.new(n, expected_point, f, fd, fdd)
  #  min.minimize
  #  min.x_minimum
  #  min.f_minimum
  #
  class NewtonRampsonMinimizer
    attr_reader :x_minimum
    attr_reader :f_minimum

    attr_writer :max_iterations
    attr_writer :epsilon
    attr_writer :golden

    # == Parameters:
    # * <tt>n</tt>: Number of Jobs
    # * <tt>expected_point</tt>: Initial point
    # * <tt>f</tt>: Original function
    # * <tt>fd</tt>: First derivative function string
    # * <tt>fdd</tt>: Second derivative function string
    #
    def initialize(n, expected_point, f, fd, fdd)
      @n              = n
      @expected_point = expected_point
      @f              = f
      @fd             = fd
      @fdd            = fdd
      @max_iterations = MAX_ITERATIONS_DEFAULT
      @epsilon        = EPSILON_DEFAULT
      @golden         = GOLDEN_DEFAULT
      @sqrt_epsilon   = SQRT_EPSILON_DEFAULT
    end

    def minimize
      # create Buffers for inputs and outputs
      expected_buffer = FFI::Buffer.alloc_inout(:pointer, @n)
      x_buffer        = FFI::Buffer.alloc_inout(:pointer, @n)
      f_buffer        = FFI::Buffer.alloc_inout(:pointer, @n)

      # set inputs
      expected_buffer.write_array_of_float(@expected_point)

      # call minimizer
      OpenCLMinimization::opencl_minimize(@n, nil, expected_buffer, nil, 1, @f, @fd, @fdd, x_buffer, f_buffer, 0,
                                          @max_iterations, @epsilon, @golden, @sqrt_epsilon, PATH_TO_KERNEL)

      @x_minimum = Array.new(@n)
      @f_minimum = Array.new(@n)
      # read results
      @x_minimum = x_buffer.read_array_of_float(@n)
      @f_minimum = f_buffer.read_array_of_float(@n)
    end
  end

  # = Bisection Minimizer.
  # Basic minimization algorithm. Slow, but robust.
  # See Unidimensional for methods.
  # == Usage.
  #  n              = 3
  #  start_point    = [1, 3, 5]
  #  expected_point = [1.5, 3.5, 5.5]
  #  end_point      = [3, 5, 7]
  #  f              = "pow((x-2)*(x-4)*(x-6), 2)+1"
  #  min = OpenCLMinimization::BisectionMinimizer.new(n, start_point, expected_point, end_point, f)
  #  min.minimize
  #  min.x_minimum
  #  min.f_minimum
  #
  class BisectionMinimizer < GodlSectionMinimizer

    def minimize
      # create Buffers for inputs and outputs
      start_buffer    = FFI::Buffer.alloc_inout(:pointer, @n)
      expected_buffer = FFI::Buffer.alloc_inout(:pointer, @n)
      end_buffer      = FFI::Buffer.alloc_inout(:pointer, @n)
      x_buffer        = FFI::Buffer.alloc_inout(:pointer, @n)
      f_buffer        = FFI::Buffer.alloc_inout(:pointer, @n)

      # set inputs
      start_buffer.write_array_of_float(@start_point)
      expected_buffer.write_array_of_float(@expected_point)
      end_buffer.write_array_of_float(@end_point)

      # call minimizer
      OpenCLMinimization::opencl_minimize(@n, start_buffer, expected_buffer, end_buffer, 2, @f, "", "", x_buffer,
                                          f_buffer, 0, @max_iterations, @epsilon, @golden, @sqrt_epsilon, PATH_TO_KERNEL)

      @x_minimum = Array.new(@n)
      @f_minimum = Array.new(@n)
      # read results
      @x_minimum = x_buffer.read_array_of_float(@n)
      @f_minimum = f_buffer.read_array_of_float(@n)
    end
  end

  # Direct port of Brent algorithm found on GSL.
  # See Unidimensional for methods.
  # == Usage
  #  n              = 3
  #  start_point    = [1, 3, 5]
  #  expected_point = [1.5, 3.5, 5.5]
  #  end_point      = [3, 5, 7]
  #  f              = "pow((x-2)*(x-4)*(x-6), 2)+1"
  #  min = OpenCLMinimization::BisectionMinimizer.new(n, start_point, expected_point, end_point, f)
  #  min.minimize
  #  min.x_minimum
  #  min.f_minimum   
  #  
  class BrentMinimizer
    attr_reader :x_minimum
    attr_reader :f_minimum

    attr_writer :max_iterations
    attr_writer :epsilon
    attr_writer :golden
    attr_writer :sqrt_epsilon

    # == Parameters:
    # * <tt>n</tt>: Number of Jobs
    # * <tt>start_point</tt>: Lower possible value
    # * <tt>expected_point</tt>: Initial point
    # * <tt>end_point</tt>: Higher possible value
    # * <tt>f</tt>: Original function string
    #
    def initialize(n, start_point, expected_point, end_point, f)
      @n              = n
      @start_point    = start_point
      @expected_point = expected_point
      @end_point      = end_point
      @f              = f
      @max_iterations = MAX_ITERATIONS_DEFAULT
      @epsilon        = EPSILON_DEFAULT
      @golden         = GOLDEN_DEFAULT
      @sqrt_epsilon   = SQRT_EPSILON_DEFAULT
    end

    def minimize
      # create Buffers for inputs and outputs
      start_buffer    = FFI::Buffer.alloc_inout(:pointer, @n)
      expected_buffer = FFI::Buffer.alloc_inout(:pointer, @n)
      end_buffer      = FFI::Buffer.alloc_inout(:pointer, @n)
      x_buffer        = FFI::Buffer.alloc_inout(:pointer, @n)
      f_buffer        = FFI::Buffer.alloc_inout(:pointer, @n)

      # set inputs
      start_buffer.write_array_of_float(@start_point)
      expected_buffer.write_array_of_float(@expected_point)
      end_buffer.write_array_of_float(@end_point)

      # call minimizer
      OpenCLMinimization::opencl_minimize(@n, start_buffer, expected_buffer, end_buffer, 3, @f, "", "", x_buffer,
                                          f_buffer, 0, @max_iterations, @epsilon, @golden, @sqrt_epsilon, PATH_TO_KERNEL)

      @x_minimum = Array.new(@n)
      @f_minimum = Array.new(@n)
      # read results
      @x_minimum = x_buffer.read_array_of_float(@n)
      @f_minimum = f_buffer.read_array_of_float(@n)
    end
  end

end
