require 'spec_helper'
require 'system_command'

describe SystemCommand do
    attr_reader :system_command, :shell_runner
    
    before do
        @shell_runner = mock 'shell'
        @system_command = SystemCommand.new 'command_name', shell_runner
        @system_command.command_line = 'some --complicated command line'
    end
    
    describe 'run' do
        it "runs a command" do
            shell_runner.should_receive(:run_command).with('some --complicated command line > command_name.out')
            system_command.run 
        end
       
        it "uses sudo if sudo user was configured" do
            system_command.sudo_as_user 'some_user' 
            shell_runner.should_receive(:run_command).with('sudo -u some_user some --complicated command line > command_name.out')
            system_command.run
        end
        
        it "returns the resulting filename" do
            shell_runner.stub(:run_command)
            system_command.run.should == 'command_name.out' 
        end 
    end
        
end
