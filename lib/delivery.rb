require 'shell_runner'


class DeliveryException < Exception; end

class Delivery
    def initialize
        @rotators = {}
        @rotators.default = Rotator.null_object
    end
    
    def add_rotator backup_name, rotator
        @rotators[backup_name] = rotator
    end
    private :add_rotator
    
    def son= rotator
        add_rotator :son, rotator 
    end
    
    def father= rotator
        add_rotator :father, rotator 
    end
    
    def grandfather= rotator
        add_rotator :grandfather, rotator 
    end
    
    def creates_a? backup_name
        @rotators[backup_name].creates_a?(backup_name)
    end

    def target_filename(archivename)
        if @rotators.empty?
            raise DeliveryException.new("no rotators defined, don't know how to determing target filename")
        end
        
        appropriate_rotator do |rotator|
            return rotator.target_filename(archivename)
        end
    end

    def deliver(file, directory)
        if @rotators.empty?
            raise DeliveryException.new("no rotators defined, don't know how to deliver")
        end
        
        appropriate_rotator do |rotator|
            rotator.execute(file, directory)
        end
    end

    private 
    def appropriate_rotator &block
        [:grandfather, :father, :son].each do |rotator_name|
            return yield @rotators[rotator_name] if @rotators[rotator_name].should_be_used?
        end
    end
end

require 'date'
class Rotator
    attr_writer :name
   
    def self.null_object
        NullRotator.new
    end
     
    def initialize(kind, shell  = ShellRunner.new)
        @shell = shell
        @kind = kind
    end
    
    def creates_a?(backup_kind)
        backup_kind.to_s == @kind.to_s
    end
    
    def name
        @name || @kind 
    end
    
    def should_be_used?
        return true
    end
    
    def target_filename(archive_name)
        [archive_name, name, Date.today.strftime('%Y-%m-%d')].join('_')
    end
    
    def execute(source, destination)
        @shell.move(source, "#{destination}/")
    end
    
    class NullRotator < Rotator
        def initialize
            super('null')
        end
        
        def should_be_used?
            false 
        end
        def execute(source, destination)
        end
    end
end
