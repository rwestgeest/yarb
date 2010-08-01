require 'spec_helper'
require 'delivery'


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

    shared_examples_for "A Delegating Delivery" do
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
    end
    
    describe 'deliver' do
        def expect_to_delegate_to_son
            son.should_receive(:execute).with('some_file', 'some directory')
        end
        def expect_to_delegate_to_father
            son.should_receive(:execute).never
            father.should_receive(:execute).with('some_file', 'some directory')
        end
        def expect_to_delegate_to_grandfather
            son.should_receive(:execute).never
            father.should_receive(:execute).never
            grandfather.should_receive(:execute).with('some_file', 'some directory')
        end
        def doit
            delivery.deliver('some_file', 'some directory')
        end
        
        it_should_behave_like "A Delegating Delivery"
    end
    
    describe 'filename' do
        def expect_to_delegate_to_son
            son.should_receive(:target_filename).with('archivename')
        end
        def expect_to_delegate_to_father
            son.should_receive(:target_filename).never
            father.should_receive(:target_filename).with('archivename')
        end
        def expect_to_delegate_to_grandfather
            son.should_receive(:target_filename).never
            father.should_receive(:target_filename).never
            grandfather.should_receive(:target_filename).with('archivename')
        end
        def doit
            delivery.target_filename('archivename')
        end
        
        it_should_behave_like "A Delegating Delivery"
    end

end

require 'date'
describe Rotator do
    attr_reader :rotator
    before do
        @rotator = Rotator.new('son',nil)
    end
    
    describe "should_be_used?" do
        it "returns true by default" do
            rotator.should_be_used?.should be_true
        end
    end
    
    describe "target_filename" do
        it "starts with the archive name" do
            rotator.target_filename('myfile').should start_with('myfile')
        end
        
        it "contains the rotator name" do
            rotator.name='daily'
            rotator.target_filename('myfile').should include('daily')
        end
        
        it "contains the rotator kind if name not defined" do
            rotator.target_filename('myfile').should include('son')
        end
        
        it "contains the date " do
            rotator.target_filename('myfile').should include(Date.today.strftime('%Y-%m-%d'))
        end
    end
    
    describe "execute" do
        it "sends the file to a rotated filename in the destination directory" do
            shell = mock('shell')
            delivery = mock
            rotator = Rotator.new('son', shell)
            shell.should_receive(:move).with('filename','destination/')
            rotator.execute('filename','destination')
        end
        it "removes destinations for this rotator until it matches the maximum to keep"
    end
end
