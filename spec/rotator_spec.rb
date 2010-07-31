require 'spec_helper'
require 'rotator'

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
