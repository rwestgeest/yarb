#!/usr/bin/env ruby
require 'spec_helper'
require 'date'
require 'backup'


class MyBackupper < Backupper
    attr_reader :type
    attr_accessor :last_month_backup, :last_week_backup
    def initialize(options = {}) 
        super({:reporter => stub('reporter').as_null_object}.merge(options))
        @type = 'none' 
        @last_month_backup = 7
        @last_week_backup = 0
    end
    def domonth(date)
        @type = 'monthly' 
    end
    def doweek(date)
        @type = 'weekly'
    end
    def doday(date)
        @type = 'daily'
    end
    
end

describe "BackupType" do
    attr_reader :backupper
    
    before do
        @backupper = MyBackupper.new
    end
    it "is a month backup on first sunday of the month" do
        backupper.backup(Date.parse("2006-07-02"))
          backupper.type.should == "monthly"
        backupper.backup(Date.parse("2006-08-06"))
         backupper.type.should == "monthly"
    end

    it "is a month backup If No MonthBackupsPresentAtAll" do
        backupper.last_month_backup = nil
        backupper.backup(Date.parse("2006-07-03"))
         backupper.type.should == "monthly"
	end    
    
    it "is a WeekBackUpOnAllOtherSundays" do
        backupper.backup(Date.parse("2006-08-13"))
         backupper.type.should == "weekly"
        backupper.backup(Date.parse("2006-08-27"))
         backupper.type.should == "weekly"
	end    

    it "is a WeekBackUpIfNoWeekBackupsPresentAtAll" do 
        backupper.last_week_backup = nil
        backupper.backup(Date.parse("2006-07-03"))
         backupper.type.should == "weekly"
	end    

    it "is a DayBackUpOnAllOtherWeekDays" do
        backupper.backup(Date.parse("2006-08-14"))
         backupper.type.should == "daily"
        backupper.backup(Date.parse("2006-08-12"))
         backupper.type.should == "daily"
	end    
end


describe Backupper do
    
    describe "a month backup" do
        attr_reader :backupper
        before do
            reporter = mock('reporter').as_null_object
            @backupper = Backupper.new :reporter => reporter
        end
        
        it "does a tar and sets the date of the last month backup" do
            backupper.should_receive(:dotar).with("monthly_2006_8")
            backupper.domonth(Date.parse("2006-08-13"))
            backupper.last_month_backup.should == Date.parse("2006-08-13")
        end

        it "does_not_rsync" do
            backupper.should_not_receive(:dosync)
            backupper.domonth(Date.parse("2006-08-13"))
        end
    end
    
    describe "week backup" do
        attr_reader :reporter
        before do
            @reporter = mock('reporter').as_null_object
        end
        
        it " does a tar and sets date of last weekbackup" do
            backupper = Backupper.new(:reporter => reporter, :last_month_backup => Date.parse("2006-08-13"))
         
            backupper.should_receive(:dotar).with("weekly_2006_8_33",Date.parse("2006-08-13"))
            backupper.doweek(Date.parse("2006-08-14"))
            backupper.last_week_backup.should == Date.parse("2006-08-14")
        end

    end

    describe "day backup" do
        attr_reader :reporter
        before do
            @reporter = mock('reporter').as_null_object
        end
        
        it "does a tar and sets date of last day bakcup" do
            backupper = Backupper.new(:reporter => reporter, :last_week_backup => Date.parse("2006-08-13"))
            backupper.should_receive(:dotar).with("daily_2006_8_33_1", Date.parse("2006-08-13"))
            backupper.doday(Date.parse("2006-08-14"))
        end
        
    end
end



