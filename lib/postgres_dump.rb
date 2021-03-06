require 'shell_runner'
require 'database_dump'

class PostgresDump < DatabaseDump
 
    protected 
    def dump_command_name
        'pg_dump'
    end
    
    private
 
    def command_options 
        return @options_override if @options_override
        options = []
        options << '--no-acl'
        options.empty? ? nil : options.join(' ')
    end 
    
    def target_filename
        "#{database_name}_postgres.dump"
    end
end

