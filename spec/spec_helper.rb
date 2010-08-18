require 'rubygems'
require 'fileutils'
PROJECT_ROOT=File.expand_path(File.join(File.dirname(__FILE__),'..'))

$: << File.join(File.dirname(__FILE__),'..','lib')

include FileUtils

class Date
    def inspect
        strftime "%d-%m-%Y"
    end
end


def create_a(backup)
    simple_matcher("create a #{backup}") {|given| given.creates_a?(backup)}
end 

def start_with(substring)
    simple_matcher("to start with #{substring}") {|given| given.start_with?(substring)}
end

def end_with(substring)
    simple_matcher("to end with #{substring}") {|given| given.end_with?(substring)}
end

def clean_input
    return unless File.exists? input_dir  
    rm_r input_dir
end

def clean_output
    return unless File.exists? output_dir  
    rm_r output_dir
end

def input_file file
    File.join(input_dir, file)
end 

def output_file file
    File.join(output_dir, file)
end

def input_dir
    File.expand_path File.join(File.dirname(__FILE__), 'input_data')
end

def output_dir
    File.expand_path File.join(File.dirname(__FILE__), 'output_data')
end

def create_input_file file
    mkdir_p File.dirname(input_file(file))
    system 'touch ' + input_file(file)
end

