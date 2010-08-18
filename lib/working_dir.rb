require 'fileutils'
class EnvironmentException < Exception; end
class WorkingDir
    include FileUtils
    def initialize(dirname)
        @dirname = dirname
    end
    
    def in(&block)
        raise EnvironmentException.new("working dir should be temp") unless @dirname.start_with?('/tmp/')
        create
        cd @dirname, &block
        rm_rf @dirname
    end
    
    private
    def create
        begin 
            mkdir_p @dirname
        rescue Exception => e
            raise EnvironmentException.new(e.message)
        end
    end
    
end
