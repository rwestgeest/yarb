#!/usr/bin/env ruby

require 'date'
require 'logger' 
require 'yaml'

require 'reporter'

class Backup
    attr_reader :archives
    attr_reader :delivery
    
    def initialize(working_dir = WorkingDir.new('/tmp/yarb'))
        @working_dir = working_dir
        @delivery = Delivery.new
        @archives = []
    end
    
    def add_archive(archive)
        @archives << archive
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
    
end



