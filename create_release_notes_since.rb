#!/usr/bin/env ruby


changes = `svn log -r HEAD:{#{File.stat('ReleaseNotes').mtime.strftime('%Y%m%d')}}`

class Change 
    attr_reader :who
    def initialize(fields)
        @revision = fields[0]
        @who = fields[1]
        @date = fields[2]
        @message = fields[3] 
    end
    
    def self.parse(text)
        fields = text.strip.split('|').collect{|field| field.strip}
        return nil if fields.empty?
        self.new(fields) 
    end

    def to_s
        message
    end
    
    def date 
        return '????-??-??' unless @date
        @date[/[^ ]+/] 
    end
    
    def revision
        return '' unless @revision
        @revision
    end
    
    
    def message
        return revision + ' ' + date unless @message 
        revision + ' ' + date + ' ' + @message.sub(/[^\n]+\n\n/, '')
    end
    
end

changes = changes.split(/\-\-+/).
        collect{|change| change.empty? ? nil : change}.compact.
        collect{|change| Change.parse(change)}.compact
changes.each {|change| puts change.message}