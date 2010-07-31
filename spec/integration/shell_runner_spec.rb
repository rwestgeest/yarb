require 'spec_helper'
require 'shell_runner'

describe ShellRunner do
    attr_reader :shell_runner
    before do 
        @shell_runner = ShellRunner.new
    end
    
    describe "run_command" do    
        it "can run a command" do
            shell_runner.run_command('ls').should == true
        end

        it "fails if the command fails" do
            shell_runner.run_command('rm garbledigook').should == false
        end
    end
    
    describe "move" do
        
        before do
            clean_input
            clean_output
        end
        
        after do
            clean_input
            clean_output
        end

        it "moves the file from source to destination" do
            create_input_file 'source_file'
            shell_runner.move(input_file('source_file'),output_file('destination/dest_file'))    
            File.should exist(output_file('destination/dest_file'))
        end
    end
end
