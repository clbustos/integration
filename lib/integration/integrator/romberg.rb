class Integration::Romberg < Integration::Integrator
  attr_accessor :h, :m, :close, :r, :j

  def initialize(lower_bound, upper_bound, n, &func)
    super
    @h = upper_bound.to_f - lower_bound
    @close = 1
    @m = 1
    @r = [[], [], [], [], [], [], [], [], [], [], [], [], []]
    @r[1][1] = (@h / 2) * (func[lower_bound] + func[upper_bound])
    @j = 1
  end

  def result
    iterate while j <= 11 && n < close
    r[j][j]
  end

  def iterate
    @j += 1
    r[j][0] = 0
    @h /=  2
    sum = (1..m).to_a.reduce(0) do |memo, k|
      memo + func[lower_bound + (h * ((2 * k) - 1))]
    end
    @m *= 2
    r[j][1] = r[j - 1][1] / 2 + (h * sum)
    (1..j - 1).each do |k|
      @r[j][k + 1] = r[j][k] + ((r[j][k] - r[j - 1][k]) / ((4**k) - 1))
    end
    @close = (r[j][j] - r[j - 1][j - 1])
  end
end
