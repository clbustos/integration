# Simpson's rule
# +n+ implies number of subdivisions
# Source:
#   * Ayres : Outline of calculus
class Integration::Simpson < Integration::Integrator
  def initialize(lower_bound, upper_bound, n, &func)
    super
    @n += 1 unless @n.even?
  end

  def result
    (step / 3.0) * (func[lower_bound.to_f].to_f + func[upper_bound.to_f].to_f + iteration)
  end

  def iteration
    (1..(n - 1)).reduce(0) do |ac, i|
      ac + (i.even? ? 2 : 4) * func[lower_bound + step * i]
    end
  end
end
