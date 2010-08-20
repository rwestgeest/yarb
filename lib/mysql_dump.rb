require 'shell_runner'
require 'database_dump'

class MysqlDump < DatabaseDump
    attr_accessor :username, :password 
    
    protected 
    def dump_command_name
        'mysqldump'
    end

    def command_options 
        return @options_override if @options_override
        options = []
        options << '-u' << @username if @username
        options << "--password=#{@password}" if @password
        options.empty? ? nil : options.join(' ')
    end 
    
    def target_filename
        "#{database_name}_mysql.dump"
    end
end

