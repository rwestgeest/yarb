PROJECT_ROOT=File.expand_path(File.join(File.dirname(__FILE__),'..'))

$: << File.join(File.dirname(__FILE__),'..','lib')


def create_a(backup)
    simple_matcher("create a #{backup}") {|given| given.creates_a?(backup)}
end 


def input_file file
    File.join(File.dirname(__FILE__), 'input_data', file)
end 

def output_file file
    File.join(File.dirname(__FILE__), 'output_data', file)
end

def create_input_file file
    mkdir_p File.dirname(input_file(file))
end

