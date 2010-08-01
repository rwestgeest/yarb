require 'shell_runner'

class Archive
    attr_reader :files, :name, :delivery, :commands
    attr_accessor :destination
    def initialize(name, delivery, shell_runner = ShellRunner.new)
        @name = name
        @delivery = delivery
        @files = []
        @commands = []
        @shell_runner = shell_runner
    end
    
    def add_file(filename)
        @files << filename
    end
    
    def add_files(*filenames)
        @files += filenames
    end
    
    def add_command(command)
        @commands << command
    end
    
    def run
        @files += @commands.collect { |command| command.run }
        @shell_runner.run_command tar_command
        @delivery.deliver(tar, destination)
    end    
    
    private 
    def tar_command
        "tar cvzf #{tar} #{input_files}"
    end
    def tar
        "#{@delivery.target_filename(name)}.tgz"
    end
    def input_files
        files.join(' ')
    end
end

