require 'spec_helper'
require 'delivery'
require 'date'
require 'date_fmt'

include DateFmt

describe Delivery do
    require 'delivery'
    attr_reader :delivery, :son, :father, :grandfather
    before do
        @delivery = Delivery.new()
        @son = mock 'son'
        @father = mock 'father'
        @grandfather = mock 'grandfather'
        @son.stub!(:should_be_used?).and_return true
    end

    
    describe 'deliver' do
        attr_reader :working_archive_file
        before do
            @working_archive_file = "some_file_#{today_as_string}.tgz"
        end

        describe 'if no rotation strategy defined' do
            it 'raises an exception' do
                lambda {
                    doit
                }.should raise_exception(DeliveryException)
            end
        end
           
        describe 'if a son strategy defined' do
            before do 
                delivery.son= son
            end
            
            it 'delegates to the son' do
                expect_to_delegate_to_son            
                doit
            end
            
            describe "and father too" do
                before do
                    delivery.father = father
                    father.stub!(:should_be_used?).and_return true
                end
                
                it 'delegates to the father if it should be used' do
                    expect_to_delegate_to_father            
                    doit
                end
                
                describe "and grandfather too" do
                    it 'delegates to the grandfather if it should be used' do
                        delivery.grandfather = grandfather
                        grandfather.stub!(:should_be_used?).and_return true
                        expect_to_delegate_to_grandfather            
                        doit
                    end
                end
            end
        end

        def expect_to_delegate_to_son
            son.should_receive(:execute).with(working_archive_file, 'some_file', 'some directory')
        end
        def expect_to_delegate_to_father
            son.should_receive(:execute).never
            father.should_receive(:execute).with(working_archive_file, 'some_file', 'some directory')
        end
        def expect_to_delegate_to_grandfather
            son.should_receive(:execute).never
            father.should_receive(:execute).never
            grandfather.should_receive(:execute).with(working_archive_file,'some_file', 'some directory')
        end
        def doit
            delivery.deliver('some_file', 'some directory')
        end
        
    end
    
    describe 'working_archive_file' do
        it "contains the archive name and the current date" do
            delivery.working_archive_file('archivename').should == "archivename_#{today_as_string}.tgz"
        end
        
    end

end

require 'date'
require 'runt'
include Runt

describe Rotator do
    attr_reader :rotator
    before do
        @rotator = Rotator.new('son',nil)
    end
    
    describe "should_be_used?" do
        it "returns true by default" do
            rotator.should_be_used?('archive_name', 'destination').should be_true
        end
        
        describe "when files of this type exist" do
            it "returns false if date does not match the should_run_on_each runt spec" do
                rotator.should_run_on_each last_friday
                rotator.should_be_used?('archive_name', 'destination', Date.parse("29-07-2010")).should be_false
            end
            
            it "returns true if date does matches the should_run_on_each runt spec" do
                rotator.should_run_on_each last_friday
                rotator.should_be_used?('archive_name', 'destination', Date.parse("30-07-2010")).should be_true
            end
        end
    end
    

    
    describe "execute" do
        attr_reader :rotator, :shell
        before do
            @shell = mock('shell')
            @rotator = Rotator.new('son', nil, shell)
        end
        it "sends the file to a rotated filename in the destination directory" do
            shell.should_receive(:move).with('working_archive_file', include("destination/archive_son_#{today_as_string}"))
            rotator.execute('working_archive_file','archive', 'destination')
        end
        
        it "removes destinations for this rotator until it matches the maximum to keep" do
            rotator.number_to_keep = 1
            shell.should_receive(:move).with('working_archive_file', include("destination/archive_son_#{today_as_string}"))
            shell.should_receive(:ordered_list).with('destination/archive_son*').and_return ['file1', 'file2', 'file3']
            shell.should_receive(:rm).with('file1')
            shell.should_receive(:rm).with('file2')
            rotator.execute('working_archive_file','archive', 'destination')
        end
    end

    describe "destination_archive_file" do
        it "starts with the archive name" do
            rotator.destination_archive_file('myarchive').should start_with('myarchive')
        end
        
        it "contains the rotator name" do
            rotator.name='daily'
            rotator.destination_archive_file('myarchive').should include('daily')
        end
        
        it "contains the rotator kind if name not defined" do
            rotator.destination_archive_file('myarchive').should include('son')
        end
        
        it "contains the date formatted for alphabetical sorting " do
            rotator.destination_archive_file('myarchive').should include(today_as_string)
        end
        
        it "ends with a tgz extension" do
            rotator.destination_archive_file('myarchive').should end_with(".tgz")
        end

    end
end
