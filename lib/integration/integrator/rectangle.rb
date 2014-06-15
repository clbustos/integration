# Rectangle method
# +n+ implies number of subdivisions
# Source:
#   * Ayres : Outline of calculus
class Integration::Rectangle < Integration::Integrator
  def result
    n.times.reduce(0) do |ac, i|
      ac + func[lower_bound + step * (i + 0.5)]
    end * step
  end
end
