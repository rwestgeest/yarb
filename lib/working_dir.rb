require 'fileutils'
class EnvironmentException < Exception; end
class WorkingDir
    include FileUtils
    def initialize(dirname)
        @dirname = dirname
    end
    
    def create
        begin 
            mkdir_p @dirname
        rescue Exception => e
            raise EnvironmentException.new(e.message)
        end
    end
end
