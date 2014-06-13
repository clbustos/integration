class Integration::Gsl
  M_INFINITY = :minfinity
  INFINITY = :infinity

  def infinite?(bound)
    bound == INFINITY || bound == M_INFINITY
  end

  attr_reader :lower_bound, :upper_bound, :options, :func
  def initialize(lower_bound, upper_bound, options, &func)
    @lower_bound = lower_bound
    @upper_bound = upper_bound
    @options = options
    @func = GSL::Function.alloc(&func)
  end

  def result
    return qag if qag?
    qng
  end

  def qng
    func.qng([lower_bound, upper_bound], [tolerance, 0.0])[0]
  end

  def qag
    w = GSL::Integration::Workspace.alloc
    return func.qagi([tolerance, 0.0], 1000, w)[0] if infinite?(lower_bound) && infinite?(upper_bound)
    return func.qagil(upper_bound, [tolerance, 0], w)[0] if infinite?(lower_bound)
    return func.qagiu(lower_bound, [tolerance, 0], w)[0] if infinite?(upper_bound)
    func.qag([lower_bound, upper_bound], [tolerance, 0.0], GSL::Integration::GAUSS61, w)[0]
  end

  def qag?
    method == :qag
  end

  def qng?
    method == :qng
  end

  def method
    options[:method]
  end

  def tolerance
    options[:tolerance]
  end
end
