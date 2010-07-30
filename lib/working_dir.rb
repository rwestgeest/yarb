
class EnvironmentException < Exception; end
class WorkingDir
    def initialize(dirname)
        @dirname = dirname
    end
    
    def create
        begin 
            mkdir_p @dirname
        rescue Exception => e
            raise EnvironmentException.new(e)
        end
    end
end
