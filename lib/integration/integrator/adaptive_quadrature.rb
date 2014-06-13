class Integration::AdaptiveQuadrature < Integration::Integrator
  def result
    h = (upper_bound.to_f - lower_bound) / 2.0
    fa = func[lower_bound]
    fc = func[lower_bound + h]
    fb = func[upper_bound]
    s = h * (fa + (4 * fc) + fb) / 3
    helper = Proc.new do |a, b, fa, fb, fc, h, s, level|
      if level < 1 / n.to_f
        fd = func[a + (h / 2)]
        fe = func[a + (3 * (h / 2))]
        s1 = h * (fa + (4.0 * fd) + fc) / 6
        s2 = h * (fc + (4.0 * fe) + fb) / 6
        if ((s1 + s2) - s).abs <= n
          s1 + s2
        else
          helper.call(a, a + h, fa, fc, fd, h / 2, s1, level + 1) +
          helper.call(a + h, b, fc, fb, fe, h / 2, s2, level + 1)
        end
      else
        fail 'Integral did not converge'
      end
    end
    return helper.call(lower_bound, upper_bound, fa, fb, fc, h, s, 1)
  end
end
