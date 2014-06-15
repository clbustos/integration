class Integration::MonteCarlo < Integration::Integrator
  attr_accessor :height, :min, :max

  def result
    area_ratio * width * height
  end

  def get_vals
    (0..n).to_a.reduce([]) do |memo, _i|
      t = lower_bound + (rand * width)
      ft = func[t]
      @min ||= ft
      @min = ft if ft < @min
      @max ||= ft
      @max = ft if ft > @max
      @height ||= ft
      @height = ft if ft > @height
      memo + [ft]
    end
  end

  def vals
    @vals ||= get_vals
  end

  def area_ratio
    vals.reduce(0) do |memo, ft|
      memo + ft / (height.to_f * n.to_f)
    end
  end

  def width
    (upper_bound - lower_bound).to_f
  end
end
