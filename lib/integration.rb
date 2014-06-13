require 'active_support/core_ext/string'

class Integration
  require 'integration/version'
  require 'integration/gsl'
  require 'integration/ruby'

  M_INFINITY = :minfinity
  INFINITY = :infinity

  RUBY_METHOD = [:rectangle, :trapezoid, :simpson,
                 :adaptive_quadrature, :gauss, :romberg, :monte_carlo]
  GSL_METHOD = [:qng, :qag]

  DEFAULT_OPTIONS = { tolerance: 1e-10, initial_step: 16, step: 16 }

  attr_reader :lower_bound, :upper_bound, :options, :func

  def self.infinite?(bound)
    bound == INFINITY || bound == M_INFINITY
  end

  def initialize(lower, upper, options = {}, &func)
    @lower_bound = lower
    @upper_bound = upper
    @options = default_options.merge(options)
    @func = func
    fails
  end

  def fails
    fail 'Non-numeric bounds' if invalid_bounds?
    fail 'Ruby methods doesnt support infinity bounds' if inifinite_bounds? && ruby_method?
    fail "Unknown integration method \"#{options[:method]}\"" unless (ruby_method? || gsl_method?)
  end

  def result
    return Integration::Ruby.new(lower_bound, upper_bound, options, &func).result if ruby_method?
    Integration::Gsl.new(lower_bound, upper_bound, options, &func).result
  end

  def default_method
    self.class.has_gsl? ? :qag : :simpson
  end

  def ruby_method?
    RUBY_METHOD.include? options[:method]
  end

  def gsl_method?
    GSL_METHOD.include? options[:method]
  end

  def default_options
    DEFAULT_OPTIONS.merge(method: default_method)
  end

  def inifinite_bounds?
    (self.class.infinite?(lower_bound) || self.class.infinite?(upper_bound))
  end

  def invalid_bounds?
    return false if inifinite_bounds?
    !((lower_bound.is_a? Numeric) && (upper_bound.is_a? Numeric))
  end

  class << self
    def create_has_library(library)
      define_singleton_method("has_#{library}?") do
        cv = "@@#{library}"
        assign_cv(library) unless class_variable_defined?(cv)
        class_variable_get(cv)
      end
    end

    def assign_cv(library)
      cv = "@@#{library}"
      require library.to_s
      class_variable_set(cv, true)
    rescue LoadError
      class_variable_set(cv, false)
    end

    def integrate(t1, t2, options = {}, &f)
      new(t1, t2, options, &f).result
    end
  end
  create_has_library :gsl
end
