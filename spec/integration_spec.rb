require 'spec_helper'

describe Integration do
  let(:function) { ->(x) { x**2 } }
  METHODS = [:rectangle, :trapezoid, :simpson, :adaptive_quadrature, :romberg]
  let(:tolerance) { 1e-8 }
  context 'over [1,2] = x^3/3 = 7/3' do
    METHODS.each do |m|
      it "calculates correct result with method #{m}" do
        res = Integration.integrate(1, 2, { method: m, tolerance: tolerance }, &function)
        expect(res).to be_within(1e-6).of(7.0 / 3)
      end
    end
  end

  context 'Trapezoid' do
    let(:a) { rand }
    let(:b) { rand * 10 }
    let(:function) { ->(x) { x * a } }
    it 'calculates valid result' do
      res = Integration.integrate(0, b, { method: :trapezoid }, &function)
      expect(res).to be_within(1e-14).of((a * b**2) / 2.0)
    end
  end

  context 'Ruby methods' do
    let(:function) { ->(x) { (1.0 / Math.sqrt(2.0 * Math::PI)) * Math.exp(-(x**2.0 / 2.0)) } }
    context 'Simpson' do
      let(:method) { :simpson }
      it 'calculates correct value' do
        res = Integration.integrate(0, 1, { tolerance: 1e-12, method: method }, &function)
        expect(res).to be_within(1e-11).of(0.341344746068)
      end
    end

    context 'Adaptive quadrature' do
      let(:method) { :adaptive_quadrature }
      it 'calculates correct value' do
        res = Integration.integrate(0, 1, { tolerance: 1e-12, method: method }, &function)
        expect(res).to be_within(1e-11).of(0.341344746068)
      end
    end
  end

  context 'GSL methods' do
    let(:function) { ->(x) { (1.0 / Math.sqrt(2.0 * Math::PI)) * Math.exp(-(x**2.0 / 2.0)) } }
    let(:lower) { 0 }
    let(:upper) { 1 }
    let(:tolerance) { 1e-12 }
    let(:imethod) { :qng }
    let(:params) do
      [
      ]
    end
    context 'QNG' do
      let(:imethod) { :qng }
      it 'calculates correct value' do
        pending('GSL not available') unless Integration.has_gsl?
        res = Integration.integrate(lower, upper, { tolerance: tolerance, method: imethod }, &function)
        expect(res).to be_within(1e-11).of(0.341344746068)
      end
    end

    context 'QAG' do
      let(:imethod) { :qag }
      it 'calculates correct value' do
        pending('GSL not available') unless Integration.has_gsl?
        res = Integration.integrate(lower, upper, { tolerance: tolerance, method: imethod }, &function)
        expect(res).to be_within(1e-11).of(0.341344746068)
      end
    end

    context 'Infinity' do
      let(:imethod) { :qag }
      let(:lower) { Integration::M_INFINITY }
      let(:upper) { Integration::INFINITY }
      context 'both' do
        let(:tolerance) { 1e-10 }
        it 'calculates correct value' do
          pending('GSL not available') unless Integration.has_gsl?
          res = Integration.integrate(lower, upper, { tolerance: tolerance, method: imethod }, &function)
          expect(res).to be_within(1e-09).of(1)
        end
      end

      context 'lower' do
        let(:upper) { 0 }
        let(:tolerance) { 1e-10 }
        it 'calculates correct value' do
          pending('GSL not available') unless Integration.has_gsl?
          res = Integration.integrate(lower, upper, { tolerance: tolerance, method: imethod }, &function)
          expect(res).to be_within(1e-09).of(0.5)
        end
      end

      context 'upper' do
        let(:lower) { 0 }
        let(:tolerance) { 1e-10 }
        it 'calculates correct value' do
          pending('GSL not available') unless Integration.has_gsl?
          res = Integration.integrate(lower, upper, { tolerance: tolerance, method: imethod }, &function)
          expect(res).to be_within(1e-09).of(0.5)
        end
      end

      it 'raises error if a ruby method is called with infinite bounds' do
        res = -> { Integration.integrate(0, upper, { method: :simpson }, &function) }
        expect(res).to raise_exception
      end
    end
  end
end
