#!/usr/bin/env ruby

require 'date'
require 'logger' 
require 'yaml'

require 'reporter'


class DeliveryException < Exception; end

class Backup
    attr_reader :archives
    
    def initialize(working_dir = WorkingDir.new('/tmp/yarb'))
        @working_dir = working_dir
        @archives = []
        @rotators = {}
    end
    
    def add_archive(archive)
        @archives << archive
    end
    
    def add_rotator backup_name, rotator
        @rotators[backup_name] = rotator
    end

    def son= rotator
        add_rotator :son, rotator 
    end
    
    def creates_a? backup_name
        @rotators[backup_name]
    end
    
    def run
        begin 
            @working_dir.create
            @archives.each { |archive| archive.run }
            return 0
        rescue DeliveryException => e
            puts "could not deliver backup to end location because: " + e
        rescue Exception => e
            puts "uh oh " + e
            return 1
        end
    end
    
    def deliver(file, directory)
        if @rotators.empty?
            raise DeliveryException.new("no rotators defined, don't know how to deliver")
        end
        @rotators[:son].execute(file, directory)
    end
end



