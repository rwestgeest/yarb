require 'abstract_command'

class DatabaseDump < AbstractCommand
    attr_reader :database_name
    attr_accessor :options_override, :extra_options
    
    def initialize(database_name, shell_runner = ShellRunner.new)
        super(shell_runner)
        @database_name = database_name
    end

    protected
    def command
        command_components = []
        command_components << "sudo -u #{@sudo_user}" if @sudo_user
        command_components << dump_command_name
        command_components << command_options
        command_components << @extra_options if @extra_options
        command_components << database_name
        command_components << '>'
        command_components << target_filename
        command_components.compact.join ' '
    end

end
