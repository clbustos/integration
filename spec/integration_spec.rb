require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe Integration do
  a=lambda {|x| x**2}
  # Integration over [1,2]=x^3/3=7/3
  methods=[:rectangle,:trapezoid, :simpson, :adaptive_quadrature,  :romberg]
  methods.each do |m|
    it "should integrate correctly with ruby method #{m}" do
      Integration.integrate(1,2,{:method=>m,:tolerance=>1e-8},&a).should be_within(1e-6).of(7.0 / 3 )
    end
  end

  it "should return correct values for get_nodes" do
    a=rand()
    f=lambda {|x| x*a}
    expected=[[0.0,1.0*a,2.0*a,3.0*a],1.0]
    Integration.get_nodes(0,3,3,&f).should==expected
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
    normal_pdf=lambda {|x| (1/Math.sqrt(2*Math::PI))*Math.exp(-(x**2/2))}
    Integration.integrate(0,1,{:tolerance=>1e-12,:method=>:qng},&normal_pdf).should be_within(1e-11).of(0.341344746068)
    Integration.integrate(0,1,{:tolerance=>1e-12,:method=>:qag},&normal_pdf).should be_within(1e-11).of(0.341344746068)
  end

      
  it "should return correct integration for infinity bounds" do
    if Integration.has_gsl?
      normal_pdf=lambda {|x| (1/Math.sqrt(2*Math::PI))*Math.exp(-(x**2/2))}

      Integration.integrate(Integration::MInfinity, Integration::Infinity,{:tolerance=>1e-10}, &normal_pdf).should be_within(1e-09).of(1)
    else
      pending("GSL not available")
    end
  end
  it "should return correct integration for infinity lower bound" do
    if Integration.has_gsl?
      normal_pdf=lambda {|x| (1/Math.sqrt(2*Math::PI))*Math.exp(-(x**2/2))}

      Integration.integrate(Integration::MInfinity, 0 , {:tolerance=>1e-10}, &normal_pdf).should be_within(1e-09).of(0.5)

    else
      pending("GSL not available")
    end
  end
 it "should return correct integration for infinity upper bound" do
    if Integration.has_gsl?

      normal_pdf=lambda {|x| (1/Math.sqrt(2*Math::PI))*Math.exp(-(x**2/2))}
      Integration.integrate(0,Integration::Infinity,{:tolerance=>1e-10}, &normal_pdf).should be_within(1e-09).of(0.5)

    else
      pending("GSL not available")
    end
  end
  it "should raise an error if a ruby methods is called with infinite bounds" do
    normal_pdf=lambda {|x| (1/Math.sqrt(2*Math::PI))*Math.exp(-(x**2/2))}
    lambda {Integration.integrate(0,Integration::Infinity,{:method=>:simpson}, &normal_pdf).should be_within(1e-09).of(0.5)}.should raise_exception()
  end
end

