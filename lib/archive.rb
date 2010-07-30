require 'shell_runner'

class Archive
    attr_reader :files, :name
    attr_accessor :destination
    def initialize(name, shell_runner = ShellRunner.new)
        @name = name
        @files = []
        @shell_runner = shell_runner
    end
    
    def add_file(filename)
        @files << filename
    end
    
    def run delivery
        @shell_runner.run_command tar_command
        delivery.deliver(temp_output, destination)
    end    
    
    private 
    def tar_command
        "tar cvzf #{temp_output} #{input_files}"
    end
    def temp_output
        "/tmp/yarb/#{name}.tgz"
    end
    def input_files
        files.join(' ')
    end
end

