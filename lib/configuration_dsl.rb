
class MainDsl
    def self.configure(backup_configuration, configuration_string=nil, &configuration_block) 
        dsl = MainDsl.new(backup_configuration)
        if configuration_string 
            dsl.instance_eval configuration_string
        else
            dsl.instance_eval &configuration_block
        end
    end 
    
    def initialize(backup_recipe)
        @backup_recipe = backup_recipe
    end
    
    def backup(&configuration_block)
        backup = Backup.new 
        BackupDsl.configure(backup, &configuration_block)
        @backup_recipe.backup = backup
    end
    
    def mail(&configuration_block)
        mail_config = MailConfiguration.new
        MailDsl.configure(mail_config, &configuration_block)
        @backup_recipe.mail_config = mail_config
    end
end

require 'archive'
require 'delivery'
class BackupDsl
    def self.configure(backup, &configuration_block)
        self.new(backup).instance_eval(&configuration_block)
    end
    
    def initialize(backup)
        @backup = backup
    end
    
    def archive(name, &configuration_block)
        archive = Archive.new(name, @backup.delivery) 
        ArchiveDsl.configure(archive, &configuration_block) 
        @backup.add_archive archive
    end
    
    def delivery(&configuration_block)
        DeliveryDsl.configure(@backup.delivery, &configuration_block)
    end
end
    
require 'delivery'
class DeliveryDsl
    def self.configure(delivery, &configuration_block)
        self.new(delivery).instance_eval(&configuration_block)
    end
    
    def initialize(delivery)
        @delivery = delivery
    end
    def son
        backup_rotator = Rotator.new 
        @delivery.son = backup_rotator
    end
    def father
        backup_rotator = Rotator.new 
        @delivery.father = backup_rotator
    end
    def grandfather
        backup_rotator = Rotator.new 
        @delivery.grandfather = backup_rotator
    end
end

class ArchiveDsl
    def self.configure(archive, &configuration_block)
        new(archive).instance_eval &configuration_block
    end
    def initialize(archive)
        @archive = archive
    end
    def file(filename)
        @archive.add_file filename
    end
    def files(*filenames)
        @archive.add_files *filenames
    end
    def destination(dirname)
        @archive.destination = dirname
    end
end

require 'mail_message'
class MailDsl
    def self.configure(mail_config, &configuration_block)
        self.new(mail_config).instance_eval(&configuration_block) 
    end
    
    def initialize(mail_config)
        @mail_config = mail_config
    end
    
    def success_mail
        @mail_config.add_mail(:succes_mail, MailMessage.new) 
    end
    
    def error_mail
        @mail_config.add_mail(:error_mail, MailMessage.new) 
    end
end

