require 'fileutils'

class ShellRunner
    include FileUtils
    def run_command(command)
        system command
    end
    
    def move(source, destination)
        mkdir_p File.dirname(destination)
        mv source, destination
    end
end
