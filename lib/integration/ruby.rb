require 'integration/integrator'
class Integration::Ruby
  M_INFINITY = :minfinity
  INFINITY = :infinity

  def infinite?(bound)
    bound == INFINITY || bound == M_INFINITY
  end

  attr_reader :lower_bound, :upper_bound, :options, :func, :current_step
  def initialize(lower_bound, upper_bound, options, &func)
    @lower_bound = lower_bound
    @upper_bound = upper_bound
    @options = options
    @func = func
    @current_step = initial_step
  end

  def result
    return non_iterative if non_iterative?
    iterative
  end

  def non_iterative
    method_obj.new(lower_bound, upper_bound, tolerance, &func).result
  end

  def iterative
    value = method_obj.new(lower_bound, upper_bound, current_step, &func).result
    previous = value + (tolerance * 2)
    diffs = []
    while (previous - value).abs > tolerance
      diffs.push((previous - value).abs)
      @current_step += step
      previous = value
      value = method_obj.new(lower_bound, upper_bound, current_step, &func).result
    end
    value
  end

  def non_iterative?
    [:adaptive_quadrature, :romberg, :gauss].include? method
  end

  def iterative?
    !non_iterative?
  end

  def method_obj
    "Integration::#{method.to_s.camelize}".constantize
  rescue
    raise "Unknown integration method \"#{method}\""
  end

  def step
    options[:step]
  end

  def initial_step
    return 10 if options[:initial_step] > 10 && method == :gauss
    options[:initial_step]
  end

  def method
    options[:method]
  end

  def tolerance
    return initial_step if method == :gauss
    options[:tolerance]
  end
end
