# Trapezoid method
# +n+ implies number of subdivisions
# Source:
#   * Ayres : Outline of calculus
class Integration::Trapezoid < Integration::Integrator
  def result
    (step / 2.0) * (func[lower_bound] + func[upper_bound] + iteration)
  end

  def iteration
    2 * (1..(n - 1)).reduce(0) do |ac, i|
      ac + func[lower_bound + step * i]
    end
  end
end
