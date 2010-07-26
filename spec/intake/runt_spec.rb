require 'spec_helper'
require 'rubygems'
require 'runt'

include Runt

class Date
    def inspect
        strftime "%d-%m-%Y"
    end
end

describe "run expressions" do

    it "can give me the last friday day of a month" do
        last_friday_of_a_month = last_friday
        last_friday_of_a_month.should be_include Date.parse("30-07-2010")
    end
    
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
    
    it "can give me the first specific weekday of the year" do
        first_day = REYear.new(1) & DIMonth.new(First,Monday)
        first_day.should be_include Date.parse("04-01-2010")
        first_day.should be_include Date.parse("05-01-2009")
        first_day.should be_include Date.parse("07-01-2008")
        first_day.should be_include Date.parse("03-01-2011")
    end
    
    it "can give me the first specific weekday of the year with sugar" do
        first_day = REYear.new(1) & first_monday
        first_day.should be_include Date.parse("04-01-2010")
        first_day.should be_include Date.parse("05-01-2009")
        first_day.should be_include Date.parse("07-01-2008")
        first_day.should be_include Date.parse("03-01-2011")
    end
    
end
