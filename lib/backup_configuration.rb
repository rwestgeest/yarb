require 'backup'
require 'archive'
require 'mail_message'
require 'configuration_dsl'
require 'working_dir'

class MailNotDefinedException < Exception ; end

class BackupConfiguration
    
    attr_accessor :backup
    attr_writer :mail_config
    
    def self.from_file(recipe_filename)
        begin
            self.from_string(File.read(recipe_filename), recipe_filename)
        rescue Errno::ENOENT
            raise "recipe file #{recipe_filename} not found"
        end
    end
    
    def self.from_string(recipe_description, filename = '')
        recipe = new 
        recipe.from_string(recipe_description, filename)
        recipe
    end

    def from_string(recipe_description, filename = '')
        begin
            MainDsl.configure(self, recipe_description, filename)
        rescue ConfigurationSyntaxError => e
            raise ConfigurationSyntaxError.new("in #{filename}: #{e}")
        rescue SyntaxError => e
            raise ConfigurationSyntaxError.new("in #{filename}: #{e}")
        end
    end 
    
    def mail(mail_id)
        raise MailNotDefinedException.new(:mail_id) unless @mail_config
        @mail_config.mail(mail_id)
    end
    
    
end

class MailConfiguration
    
    def add_mail(mail_id, mail_message) 
        @mail_message = mail_message
    end
    
    def mail(mail_id)
        @mail_message
    end
end




