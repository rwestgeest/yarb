require 'shell_runner'


class DeliveryException < Exception; end

class Delivery
    def initialize
        @backup_kinds = {}
        @backup_kinds.default = BackupKind.null_object
    end
    
    def add_backup_kind backup_name, backup_kind
        @backup_kinds[backup_name] = backup_kind
    end
    private :add_backup_kind
    
    def son= backup_kind
        add_backup_kind :son, backup_kind 
    end
    
    def son
        @backup_kinds[:son]
    end
    
    def father= backup_kind
        add_backup_kind :father, backup_kind 
    end
    
    def father
        @backup_kinds[:father]
    end
    
    def grandfather= backup_kind
        add_backup_kind :grandfather, backup_kind 
    end

    def grandfather
        @backup_kinds[:grandfather]
    end
    
    def creates_a? backup_name
        @backup_kinds[backup_name].creates_a?(backup_name)
    end

    def deliver(archive)
        if @backup_kinds.empty?
            raise DeliveryException.new("no backup_kinds defined, don't know how to deliver")
        end
        
        grandfather.execute(archive) or father.execute(archive) or son.execute(archive) 

    end

end

require 'date'
class BackupKind
    attr_reader :kind
    attr_writer :name
    attr_accessor :number_to_keep
   
    def self.null_object
        NullBackupKind.new
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
    
    def should_be_used?(archive, date = Date.today)
        return true unless @should_run_on_each
        return true unless archive.exists?(name)
        @should_run_on_each.include?(date)
    end
    
    def should_run_on_each runt_spec
        @should_run_on_each = runt_spec
    end
    
    def should_run_on? date
        @should_run_on_each.include? date
    end
    
    def execute(archive, date = Date.today)
        return false unless should_be_used?(archive, date)
        archive.create(name)
        archive.remove_exceeding(name, number_to_keep) if (number_to_keep > 0)
        return true
    end

        
    class NullBackupKind < BackupKind
        def initialize
            super('null','null')
        end
        def execute(archive)
            false
        end
    end
end
