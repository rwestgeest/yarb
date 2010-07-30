PROJECT_ROOT=File.expand_path(File.join(File.dirname(__FILE__),'..'))

$: << File.join(File.dirname(__FILE__),'..','lib')


def create_a(backup)
    simple_matcher("create a backup") {|given| given.creates_a?(backup)}
end 

