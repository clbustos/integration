class Integration::Integrator
  require 'integration/integrator/simpson'
  require 'integration/integrator/rectangle'
  require 'integration/integrator/trapezoid'
  require 'integration/integrator/adaptive_quadrature'
  require 'integration/integrator/gauss'
  require 'integration/integrator/romberg'
  require 'integration/integrator/monte_carlo'

  attr_reader :lower_bound, :upper_bound, :n, :func

  def initialize(lower, upper, n, &func)
    @lower_bound = lower
    @upper_bound = upper
    @n = n
    @func = func
  end

  def step
    @step ||= (upper_bound - lower_bound) / n.to_f
  end
end
