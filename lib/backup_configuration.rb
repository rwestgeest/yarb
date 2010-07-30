require 'backup'
require 'archive'
require 'mail_message'
require 'configuration_dsl'

class MailNotDefinedException < Exception ; end

class BackupConfiguration
    attr_accessor :backup
    attr_writer :mail_config
    
    def self.from_file(recipe_filename)
        self.from_string(File.read(recipe_filename))
    end
    
    def self.from_string(recipe_description)
        recipe = new 
        recipe.from_string(recipe_description)
        recipe
    end

    def from_string(recipe_description)
        MainDsl.configure(self, recipe_description)
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



class ArchiveRecipe
    attr_reader :name, :files
    
    def self.from_configuration_block(name, &configuration_block)
        recipe = ArchiveRecipe.new(name)
        recipe.instance_eval &configuration_block
        return recipe
    end
    
    def initialize(name, output_data = nil)
        @name = name
        @destination_directory = output_data
        @files = []
    end
    
    def file file_or_directory
        add_file(file_or_directory)
    end
    
    def add_file(file_or_directory)
        @files << file_or_directory
    end
    
    def destination destination_directory
        @destination_directory = destination_directory
    end
    
    def include?(file)
        @files.include? file 
    end
    
    def written_to?(destination)
        destination == @destination_directory
    end
    
    def ==(other)
        return false unless other.is_a? ArchiveRecipe
        name == other.name && files == other.files
    end
end

