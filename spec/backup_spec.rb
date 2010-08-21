#!/usr/bin/env ruby
require 'spec_helper'
require 'date'
require 'backup'

describe Backup do
    describe 'run' do
        attr_reader :archive, :backup, :working_dir
        
        before do 
            @working_dir = mock 'working dir'
            @archive = mock 'archive'
            @backup = Backup.new nil, working_dir
            @backup.add_archive archive
        end
        
        it "runs an archive task and returns 0" do
            working_dir.should_receive(:in).and_yield
            archive.should_receive(:run).with(no_args)
            backup.run.should == 0
        end
        
        it "runs multiple archive tasks and returns 0" do
            working_dir.should_receive(:in).and_yield
            archive2 = mock 'archive2'
            backup.add_archive(archive2)                        
            archive.should_receive(:run).with(no_args)
            archive2.should_receive(:run).with(no_args)
            backup.run.should == 0
        end
        
        it "should return 1 when archive raises an error" do
            working_dir.should_receive(:in).and_yield
            archive.should_receive(:run).and_raise 'some exception'
            backup.run.should == 1
        end
    end
end



