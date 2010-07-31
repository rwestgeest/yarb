require 'spec_helper'
require 'delivery'

describe Delivery do
    require 'delivery'
    
    describe 'deliver' do
        attr_reader :delivery, :son
        before do
            @delivery = Delivery.new()
        end
        
        describe 'if no rotation strategy defined' do
            it 'raises an exception' do
                lambda {
                    delivery.deliver('some_file', 'some directory')
                }.should raise_exception(DeliveryException)
            end
        end
           
        describe 'if a son strategy defined' do
            before do 
                @son = mock
                delivery.son= son
            end
            
            it 'delivers though the son' do
                son.should_receive(:execute).with('some_file', 'some directory')
                delivery.deliver('some_file', 'some directory')
            end
        end

    end
end

describe Rotator do
    describe "rotate" do
        it "sends the file to a rotated filename in the destination directory" do
            shell = mock('shell')
            rotator = Rotator.new(shell)
            rotator.name = 'yearly'
            shell.should_receive(:move).with('/tmp/yarb/filename','destination/yearly_filename')
            rotator.execute('filename','destination')
        end
    end
end
