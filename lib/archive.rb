require 'shell_runner'

class Archive
    attr_reader :files, :name, :delivery
    attr_accessor :destination
    def initialize(name, delivery, shell_runner = ShellRunner.new)
        @name = name
        @delivery = delivery
        @files = []
        @shell_runner = shell_runner
    end
    
    def add_file(filename)
        @files << filename
    end
    
    def add_files(*filenames)
        @files += filenames
    end
    
    def run 
        @shell_runner.run_command tar_command
        @delivery.deliver(tar, destination)
    end    
    
    private 
    def tar_command
        "tar cvzf #{temp_output} #{input_files}"
    end
    def temp_output
        "/tmp/yarb/#{tar}"
    end
    def tar
        "#{name}.tgz"
    end
    def input_files
        files.join(' ')
    end
end

