require 'shell_runner'


class DeliveryException < Exception; end

class Delivery
    def initialize
        @rotators = {}
    end
    
    def add_rotator backup_name, rotator
        @rotators[backup_name] = rotator
    end
    private :add_rotator
    
    def son= rotator
        add_rotator :son, rotator 
    end
    
    def creates_a? backup_name
        @rotators[backup_name]
    end

    def deliver(file, directory)
        if @rotators.empty?
            raise DeliveryException.new("no rotators defined, don't know how to deliver")
        end
        @rotators[:son].execute(file, directory)
    end

end

class Rotator
    attr_accessor :name
    
    def initialize(shell  = ShellRunner.new)
        @shell = shell
    end
    
    def execute(source, destination)
        @shell.move('/tmp/yarb/'+source, "#{destination}/#{name}_#{source}")
    end
end
