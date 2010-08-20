require 'abstract_command'

class SystemCommand < AbstractCommand
    attr_accessor :command_line
    
    def initialize(command_name, shell_runner = ShellRunner.new)
        super(shell_runner)
        @command_name = command_name
    end 

    def name 
        @command_name
    end 
        
    def runs?(expected_command_line)
        command_line == expected_command_line
    end 
    
    protected
    def command
        command_components = []
        command_components << "sudo -u #{@sudo_user}" if @sudo_user
        command_components << "#{command_line} > #{target_filename}"
        command_components.join(' ')
    end
     
    def target_filename
        @command_name + '.out'
    end
end

