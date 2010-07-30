require 'spec_helper'
require 'shell_runner'

describe ShellRunner do
    attr_reader :shell_runner
    before do 
        @shell_runner = ShellRunner.new
    end
    
    it "can run a command" do
        shell_runner.run_command('ls').should == true
    end

    it "fails if the command fails" do
        shell_runner.run_command('rm garbledigook').should == false
    end

end
