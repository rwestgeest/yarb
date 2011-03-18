require 'spec_helper'
require 'runt_ext'

include Runt

describe "run expressions" do

  describe "xth day of a month" do
    it "can give me the last friday day of a month" do
        last_friday_of_a_month = last_friday
        last_friday_of_a_month.should be_include Date.parse("30-07-2010")
    end
    it "complains about illegal month" do
        lambda {
            first_monday_in_garble
            }.should raise_exception("garble is not a valid month")
    end
  end

  describe "first day of a year" do
    it "can give me the first day in a year" do
      first_day = REYear.new(1,1,1,1)
      first_day.should be_include Date.parse("01-01-2010")
      first_day.should be_include Date.parse("01-01-2009")
    end
    
    it "can give me the first day in a year with syntactic sugar" do
      pending 'bug submitted in runt project'
      first_day = yearly_january_1_to_january_1
      first_day.should be_include Date.parse("01-01-2010")
      first_day.should be_include Date.parse("01-01-2009")
    end

    it "january first should match its REYear expression" do
      pending 'bug submitted in runt project'
      yearly_january_1_to_january_1.should == REYear.new(1,1,1,1)
    end
  end

  describe "first specified weekday of a year" do
    it "can be specified with REYear and DIMonth objects" do
      first_day = REYear.new(1) & DIMonth.new(First,Monday)
      first_day.should be_include Date.parse("04-01-2010")
      first_day.should be_include Date.parse("05-01-2009")
      first_day.should be_include Date.parse("07-01-2008")
      first_day.should be_include Date.parse("03-01-2011")
    end
    
    it "can be specified with REYear object and DIMonth syntactic sugar" do
      first_day = REYear.new(1) & first_monday
      first_day.should be_include Date.parse("04-01-2010")
      first_day.should_not be_include Date.parse("01-02-2010")
      first_day.should be_include Date.parse("05-01-2009")
      first_day.should be_include Date.parse("07-01-2008")
      first_day.should be_include Date.parse("03-01-2011")
    end

    it "can be specified completely with syntactic sugar" do
      first_day = first_monday_in_january
      first_day.should include Date.parse("04-01-2010")
      first_day.should_not include Date.parse("01-02-2010")
      first_day.should include Date.parse("05-01-2009")
      first_day.should include Date.parse("07-01-2008")
      first_day.should include Date.parse("03-01-2011")
    end

    it "does not include first specified weekdays in other months" do
      first_day = first_sunday_in_january
      first_day.should include Date.parse("02-01-2011")
      first_day.should_not include Date.parse("06-02-2011")
      first_day.should_not include Date.parse("06-03-2011")
    end
  end

end
