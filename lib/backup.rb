#!/usr/bin/env ruby

require 'date'
require 'logger' 
require 'yaml'
require 'archive'
require 'delivery'

class Backup
    attr_reader :archives
    attr_reader :delivery
    
    def initialize(shell, working_dir = WorkingDir.new('/tmp/yarb'))
        @working_dir = working_dir
        @delivery = Delivery.new
        @archives = []
        @shell = shell
    end
    
    def create_archive(name)
        archive = Archive.new(name, delivery, @shell)
        add_archive archive
        return archive
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
           # puts e.backtrace
        end
        return 1
    end
    
end



