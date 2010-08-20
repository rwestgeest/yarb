class ConfigurationSyntaxError < Exception
end 

class Dsl
    def initialize(block_name)
        @block_name = block_name
    end
    def configure(configuration_string=nil, configuration_filename = '', &configuration_block) 
        begin 
            if configuration_string 
                instance_eval configuration_string, configuration_filename
            else
                instance_eval &configuration_block
            end
        rescue NameError => e
            raise ConfigurationSyntaxError.new("can't configure '#{e.name}' in #{@block_name}")
        end 
    end
end

class MainDsl < Dsl
    def self.configure(backup_configuration, configuration_string=nil, configuration_filename = '', &configuration_block) 
        dsl = MainDsl.new('recipe', backup_configuration)
        dsl.configure(configuration_string, configuration_filename, &configuration_block)
    end 
    
    def initialize(block_name, backup_recipe)
        super(block_name)
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
class BackupDsl < Dsl
    def self.configure(backup, &configuration_block)
        self.new('backup', backup).configure(&configuration_block)
    end
    
    def initialize(block_name, backup)
        super(block_name)
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
class DeliveryDsl < Dsl
    def self.configure(delivery, &configuration_block)
        self.new('delivery', delivery).configure(&configuration_block)
    end
    
    def initialize(block_name, delivery)
        super(block_name)
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

class RotatorDsl < Dsl
    include Runt
    def self.configure(rotator, &configuration_block) 
        instance = new(rotator.name, rotator)
        instance.configure &configuration_block if block_given?
        return instance
    end
    
    def initialize(block_name, rotator)
        super(block_name)
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
require 'mysql_dump'
require 'system_command'
class ArchiveDsl < Dsl
    def self.configure(archive, &configuration_block)
        new(archive.name, archive).configure &configuration_block
    end
    def initialize(block_name, archive)
        super(block_name)
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
    
    def mysql_database(name, &configuration_block)
        database_dump = MysqlDump.new(name)
        MysqlDumpDsl.configure(database_dump, &configuration_block)
        @archive.add_command database_dump
    end
    
    def system_command(name, &configuration_block)
        command = SystemCommand.new(name)
        SystemCommandDsl.configure(command, &configuration_block)
        @archive.add_command command
    end

end

class DatabaseDumpDsl < Dsl
    def initialize(database_dump)
        super(database_dump.database_name)
        @database_dump = database_dump
    end
    def sudo_as(username)
        @database_dump.sudo_as_user(username)
    end
    def extra_options(options)
        @database_dump.extra_options= options
    end
    def override_options(options)
        @database_dump.options_override= options
    end
end

class PostgresDumpDsl < DatabaseDumpDsl
    def self.configure(database_dump, &configuration_block)
        new(database_dump).configure &configuration_block
    end
end

class MysqlDumpDsl < DatabaseDumpDsl
    def self.configure(database_dump, &configuration_block)
        new(database_dump).configure &configuration_block
    end
    
    def user(username)
        @database_dump.username = username
    end
    
    def password(password)
        @database_dump.password = password
    end
end


class SystemCommandDsl < Dsl
    def self.configure(command, &configuration_block)
        new(command.name, command).configure &configuration_block
    end
    def initialize(block_name, command)
        super(block_name)
        @command = command
    end
    def sudo_as(username)
        @command.sudo_as_user(username)
    end
    def run(command_line)
        @command.command_line = command_line
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

