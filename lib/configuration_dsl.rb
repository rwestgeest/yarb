
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
require 'runt'
class DeliveryDsl
    def self.configure(delivery, &configuration_block)
        self.new(delivery).instance_eval(&configuration_block)
    end
    
    def initialize(delivery)
        @delivery = delivery
    end
    def son(name = nil, &configuration_block)
        @delivery.son = configure_rotator('son',name, &configuration_block) 
    end
    def father(name = nil, &configuration_block)
        @delivery.father = configure_rotator('father',name, &configuration_block) 
    end
    def grandfather(name = nil, &configuration_block)
        @delivery.grandfather = configure_rotator('grandfather',name, &configuration_block) 
    end
    
    private 
    def configure_rotator(type, name, &configuration_block) 
        backup_rotator = Rotator.new(type, name) 
        RotatorDsl.configure(backup_rotator, &configuration_block)
        return backup_rotator
    end
end

class RotatorDsl 
    include Runt
    def self.configure(rotator, &configuration_block) 
        instance = new(rotator)
        instance.instance_eval &configuration_block if block_given?
        return instance
    end
    
    def initialize(rotator)
        @rotator = rotator
    end

    def name(name)
        @rotator.name = name
    end
    
    def keep(amount)
        @rotator.number_to_keep = amount
    end
    
    def on_each(runt_expression)
        @rotator.should_run_on_each(runt_expression)
    end
end

require 'postgres_dump'
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
    
    def postgres_database(name, &configuration_block)
        database_dump = PostgresDump.new(name)
        PostgresDumpDsl.configure(database_dump, &configuration_block)
        @archive.add_command database_dump
    end
end

class PostgresDumpDsl
    def self.configure(database_dump, &configuration_block)
        new(database_dump).instance_eval &configuration_block
    end
    def initialize(database_dump)
        @database_dump = database_dump
    end
    def sudo_as(username)
        @database_dump.sudo_as_user(username)
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

