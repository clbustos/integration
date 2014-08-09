require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe Integration do
  a=lambda {|x| x**2}
  b=lambda {|x| Math.log(x)/x**2}
  b2=lambda {|x| -(Math.log(x)+1)/x}
  # Integration over [1,2]=x^3/3=7/3
  methods=[:rectangle,:trapezoid, :simpson, :adaptive_quadrature,  :romberg, :gauss, :gauss_kronrod, :simpson3by8, :boole, :open_trapezoid, :milne]
  methods.each do |m|
    it "should integrate int_{1}^2{2} x^2 correctly with ruby method #{m}" do
      Integration.integrate(1,2,{:method=>m,:tolerance=>1e-8},&a).should be_within(1e-6).of(7.0 / 3 )
    end
    it "should integrate int_{1}^2{2} log(x)/x^2 correctly with ruby method #{m}" do
      Integration.integrate(1,2,{:method=>m,:tolerance=>1e-8},&b).should be_within(1e-6).of(
        b2[2]-b2[1]
       )
    end

  end


  it "should return correct for trapezoid" do
    a=rand()
    b=rand()*10
    f=lambda {|x| x*a}
    Integration.trapezoid(0,b,2,&f).should be_within(1e-14).of((a*b**2) / 2.0)
  end
  it "should return a correct value for a complex integration with ruby methods" do
    normal_pdf=lambda {|x| (1/Math.sqrt(2*Math::PI))*Math.exp(-(x**2/2))}
    Integration.integrate(0,1,{:tolerance=>1e-12,:method=>:simpson},&normal_pdf).should be_within(1e-11).of(0.341344746068)
    Integration.integrate(0,1,{:tolerance=>1e-12,:method=>:adaptive_quadrature},&normal_pdf).should be_within(1e-11).of(0.341344746068)
  end
  it "should return a correct value for a complex integration with gsl methods" do
    if Integration.has_gsl?
      normal_pdf=lambda {|x| (1/Math.sqrt(2*Math::PI))*Math.exp(-(x**2/2))}
      Integration.integrate(0,1,{:tolerance=>1e-12,:method=>:qng},&normal_pdf).should be_within(1e-11).of(0.341344746068)
      Integration.integrate(0,1,{:tolerance=>1e-12,:method=>:qag},&normal_pdf).should be_within(1e-11).of(0.341344746068)
    else
      skip("GSL not available")
    end
  end

      
  it "should return correct integration for infinity bounds" do
    if Integration.has_gsl?
      normal_pdf=lambda {|x| (1/Math.sqrt(2*Math::PI))*Math.exp(-(x**2/2))}

      Integration.integrate(Integration::MInfinity, Integration::Infinity,{:tolerance=>1e-10}, &normal_pdf).should be_within(1e-09).of(1)
    else
      skip("GSL not available")
    end
  end
  it "should return correct integration for infinity lower bound" do
    if Integration.has_gsl?
      normal_pdf=lambda {|x| (1/Math.sqrt(2*Math::PI))*Math.exp(-(x**2/2))}

      Integration.integrate(Integration::MInfinity, 0 , {:tolerance=>1e-10}, &normal_pdf).should be_within(1e-09).of(0.5)

    else
      skip("GSL not available")
    end
  end
 it "should return correct integration for infinity upper bound" do
    if Integration.has_gsl?

      normal_pdf=lambda {|x| (1/Math.sqrt(2*Math::PI))*Math.exp(-(x**2/2))}
      Integration.integrate(0,Integration::Infinity,{:tolerance=>1e-10}, &normal_pdf).should be_within(1e-09).of(0.5)

    else
      skip("GSL not available")
    end
  end
  it "should raise an error if a ruby methods is called with infinite bounds" do
    normal_pdf=lambda {|x| (1/Math.sqrt(2*Math::PI))*Math.exp(-(x**2/2))}
    lambda {Integration.integrate(0,Integration::Infinity,{:method=>:simpson}, &normal_pdf).should be_within(1e-09).of(0.5)}.should raise_exception()
  end
end

