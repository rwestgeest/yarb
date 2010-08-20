class AbstractCommand
    attr_reader :sudo_user
    
    def initialize(shell_runner)
        @shell_runner = shell_runner
    end
    
    def sudo_as_user(username)
        @sudo_user = username 
    end

    def run
        @shell_runner.run_command(command)
        return target_filename        
    end
end
