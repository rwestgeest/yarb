require 'fileutils'
require 'string_ext'

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
    
    def rm(filepath)
        super(filepath)
    end
    
    def ordered_list(path)
        path << '/*' if File.directory?(path)
        Dir[path].sort
    end
    
    def exists?(path)
        not Dir[path].empty?
    end

end

class ShellLogger < ShellRunner
    def run_command(command)
        puts command
    end
    
    def move(source, destination)
        puts "moving #{source} to #{destination}"
    end
    
    def rm(filepath)
        puts "removing #{filepath}"
    end
end
