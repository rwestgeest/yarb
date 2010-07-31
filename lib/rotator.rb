require 'shell_runner'

class Rotator
    attr_accessor :name
    
    def initialize(shell  = ShellRunner.new)
        @shell = shell
    end
    
    def execute(source, destination)
        @shell.move('/tmp/yarb/'+source, "#{destination}/#{name}_#{source}")
    end
end
