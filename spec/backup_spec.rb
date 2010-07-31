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
            @backup = Backup.new working_dir
            @backup.add_archive archive
        end
        
        it "runs an archive task and returns 0" do
            working_dir.should_receive(:create)
            archive.should_receive(:run).with(no_args)
            backup.run.should == 0
        end
        
        it "should return 1 when archive raises an error" do
            working_dir.should_receive(:create)
            archive.should_receive(:run).and_raise 'some exception'
            backup.run.should == 1
        end
    end
    
    describe 'deliver' do
        attr_reader :backup, :son
        before do
            @backup = Backup.new(mock("working dir").as_null_object)
        end
        
        describe 'if no rotation strategy defined' do
            it 'raises an exception' do
                lambda {
                    backup.deliver('some_file', 'some directory')
                }.should raise_exception(DeliveryException)
            end
        end
           
        describe 'if a son strategy defined' do
            before do 
                @son = mock
                backup.son = son
            end
            
            it 'delivers though the son' do
                son.should_receive(:execute).with('some_file', 'some directory')
                backup.deliver('some_file', 'some directory')
            end
        end

    end
end



