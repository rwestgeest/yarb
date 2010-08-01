#!/usr/bin/env ruby

require 'date'
require 'logger' 
require 'yaml'

require 'delivery'

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
            @working_dir.in do 
                @archives.each { |archive| archive.run }
                return 0
            end
        rescue DeliveryException => e
            puts "could not deliver backup to end location because: " + e
          #  puts e.backtrace
        rescue Exception => e
            puts "uh oh " + e
          #  puts e.backtrace
        end
        return 1
    end
    
end



