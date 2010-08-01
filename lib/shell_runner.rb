require 'fileutils'

class ShellRunner
    include FileUtils
    def run_command(command)
        system command
    end
    
    def move(source, destination)
        if destination.end_with?('/')
            mkdir_p destination
        else
            mkdir_p File.dirname(destination)
        end
        mv source, destination
    end
end
