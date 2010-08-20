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
    
    def son
        @rotators[:son]
    end
    
    def father= rotator
        add_rotator :father, rotator 
    end
    
    def father
        @rotators[:father]
    end
    
    def grandfather= rotator
        add_rotator :grandfather, rotator 
    end

    def grandfather
        @rotators[:grandfather]
    end
    
    def creates_a? backup_name
        @rotators[backup_name].creates_a?(backup_name)
    end

    def working_archive_file(archive_name)
        "#{archive_name}_#{Date.today.strftime('%Y-%m-%d')}.tgz"
    end

    def deliver(archive_name, directory)
        if @rotators.empty?
            raise DeliveryException.new("no rotators defined, don't know how to deliver")
        end
        
        grandfather.execute(working_archive_file(archive_name), archive_name, directory) or
                father.execute(working_archive_file(archive_name), archive_name, directory) or
                        son.execute(working_archive_file(archive_name), archive_name, directory) 

    end

end

require 'date'
class Rotator
    attr_reader :kind
    attr_writer :name
    attr_accessor :number_to_keep
   
    def self.null_object
        NullRotator.new
    end
     
    def initialize(kind, name, shell  = ShellRunner.new)
        @shell = shell
        @kind = kind
        @name = name
        @number_to_keep = 0
    end
    
    def creates_a?(backup_kind)
        backup_kind.to_s == @kind.to_s
    end
    
    def name
        @name || @kind 
    end
    
    def should_be_used?(archive_name, destination, date = Date.today)
        return true unless @should_run_on_each
        return true unless @shell.exists?("#{destination}/#{base_name(archive_name)}*")
        @should_run_on_each.include?(date)
    end
    
    def should_run_on_each runt_spec
        @should_run_on_each = runt_spec
    end
    
    def should_run_on? date
        @should_run_on_each.include? date
    end
    
    def destination_archive_file(archive_name)
        [base_name(archive_name), Date.today.strftime('%Y-%m-%d')].join('_') + '.tgz'
    end
    
    def execute(working_archive_file, archive_name, destination, date = Date.today)
        return false unless should_be_used?(archive_name, destination, date)
        @shell.move(working_archive_file, "#{destination}/#{destination_archive_file(archive_name)}")
        if (number_to_keep > 0)
            filelist = @shell.ordered_list("#{destination}/#{base_name(archive_name)}*") 
            while filelist.size > number_to_keep
                @shell.rm filelist.shift 
            end
        end
        return true
    end

    def base_name(archive_name)
        [archive_name, name].join('_')
    end
    private :base_name
        
    class NullRotator < Rotator
        def initialize
            super('null','null')
        end
        
        def should_be_used?(archive_name, destination)
            false 
        end
        def execute(sourcefile, archive, destination)
            false
        end
    end
end
