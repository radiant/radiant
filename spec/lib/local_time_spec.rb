require File.dirname(__FILE__) + "/../spec_helper"

class MockTime
  include LocalTime
end

describe LocalTime, "when included in a class" do 
  it "should add the adjust_time instance method to the class" do
    MockTime.new.should respond_to(:adjust_time)
  end
end

describe LocalTime, "when adjusting the time to local" do
  before :each do
    @obj = MockTime.new
    @conf = Radiant::Config
    @time = Time.gm 2004
  end
  
  it "should not change the time when no timezone is specified" do
    @obj.adjust_time(@time).should == @time
  end
  
  it "should not change the time when an invalid timezone is specified" do
    @conf["local.timezone"] = "Timezone that doesn't exist"
    @obj.adjust_time(@time).should == @time
  end
  
  it "should properly adjust the time when a numeric offset is specified" do
    offset = -10.hours
    @conf["local.timezone"] = offset
    @obj.adjust_time(@time).should == @time + offset
  end
  
  it "should properly adjust the time when a named timezone is specified" do
    offset = 9.hours # Tokyo
    @conf["local.timezone"] = "Tokyo"
    @obj.adjust_time(@time).should == @time + offset
  end
end
