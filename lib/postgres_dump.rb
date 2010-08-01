require 'shell_runner'

class PostgresDump
    attr_reader :database_name, :sudo_user
    def initialize(database_name, shell_runner = ShellRunner.new)
        @database_name = database_name
        @shell_runner = shell_runner
    end
    
    def sudo_as_user(username)
        @sudo_user = username 
    end
    
    def run
        @shell_runner.run_command(command)
        target_filename        
    end
    
    private

    def command
        sudo_if_necessary + "pg_dump --no-acl #{database_name} > #{target_filename}"        
    end

    def sudo_if_necessary
        @sudo_user && "sudo -u #{@sudo_user} " || ''   
    end
    
    def target_filename
        "#{database_name}_postgres.dump"
    end
end

