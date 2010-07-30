#!/usr/bin/env ruby
require 'spec_helper'
require 'date'
require 'backup'

describe Backup do
    attr_reader :archive, :backup
    
    before do 
        @archive = mock 'archive'
        @backup = Backup.new
        @backup.add_archive archive
    end
    
    it "runs an archive task and returns 0" do
        archive.should_receive(:run)
        backup.run.should == 0
    end
    
    it "should return 1 when archive raises an error" do
        archive.should_receive(:run).and_raise 'some exception'
        backup.run.should == 1
    end
end



