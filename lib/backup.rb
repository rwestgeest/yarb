#!/usr/bin/env ruby

require 'date'
require 'logger' 
require 'yaml'

require 'reporter'


class Backup
    attr_reader :archives
    
    def initialize
        @archives = []
        @rotators = {}
    end
    
    def add_archive(archive)
        @archives << archive
    end
    
    def add_rotator backup_name, rotator
        @rotators[:backup_name] = rotator
    end
    
    def creates_a? backup_name
        @rotators[:backup_name]
    end
    
    def run
        begin 
            @archives.each { |archive| archive.run }
            return 0
        rescue Exception => e
            return 1
        end
    end
end

class BackupStatus
    attr_reader :last_month_backup, :last_week_backup
    def initialize(last_month_backup, last_week_backup)
        @last_month_backup = last_month_backup
        @last_week_backup = last_week_backup
    end
end

class Backupper
    attr_reader :last_month_backup, :last_week_backup
    
    attr_reader :errors, :infos
    
    YamlFile = '/etc/backup.yml'
    RemoteHost = 'elshof'
    User = 'westgeest'
    Filelist = '/etc/backup_filelist'
    BackupLocation = '/brick/backups/yosemite/'
    CustomerMail = 'rob@westgeest-consultancy.com'
    MaintainerMail = 'rob@westgeest-consultancy.com'
    
    
    def initialize(options = {})
        @reporter = options[:reporter] || Reporter.from_configuration_file
        @last_month_backup = options[:last_month_backup]
        @last_week_backup = options[:last_week_backup]
    end

    def do_sys(command)
        info("executing '#{command}'")
        if system(command)
            info("successful '#{command}'")
            return true
        end
        error("failed '#{command}'")
        return false
    end
    
    def dotar(filename, changes_since = nil)
        filepath = BackupLocation + filename + '.tar' 
        if changes_since
            do_sys "tar cvf #{filepath} --newer #{changes_since} -T #{Filelist} > #{filepath}.log"
        else
            do_sys "tar cvf #{filepath} -T #{Filelist} > #{filepath}.log"
        end
    end
    
    def domonth(date)
        info "starting monthly backup on #{date}" 
        dotar("monthly_#{date.year}_#{date.month}")
        @last_month_backup = date
        @reporter.report("maandelijkse backup #{date}" )
    end
    
    def doweek(date)
        info "starting weekly backup on #{date}; last monthly was on #{@last_month_backup}" 
        dotar("weekly_#{date.year}_#{date.month}_#{date.cweek}", @last_month_backup)
        @last_week_backup = date
        @reporter.report("wekelijkse backup #{date}" )
    end
    
    def doday(date)
        info "starting daily backup on #{date}; last weekly was on #{@last_week_backup}" 
        dotar(day_backup_name(date), @last_week_backup)
        @reporter.report("dagelijkse backup #{date}" )
    end
    
    def day_backup_name(date)
        "daily_#{date.year}_#{date.month}_#{date.cweek}_#{date.cwday}"
    end
    
    def backup(date)
        return domonth(date) unless last_month_backup
        return doweek(date) unless last_week_backup
        return doday(date) unless (date.cwday == 7) 
        return domonth(date) if date.month != (date-7).month 
        return doweek(date)
    end

    def error(message)
        @reporter.error message
    end
    
    def info(message)
        @reporter.info message
    end
    
    def backup_status
        BackupStatus.new(@last_month_backup, @last_week_backup)
    end
    
    def backup_status=(status)
        @last_month_backup = status.last_month_backup
        @last_week_backup = status.last_week_backup
    end

end

if __FILE__ == $0
    backupper = nil
    backupper = Backupper.new()
    if File.exists?(Backupper::YamlFile) 
        File.open(Backupper::YamlFile) { |f| backupper.backup_status = YAML.load(f) } 
    end 
    backupper.backup(Date.today)
    File.open(Backupper::YamlFile, 'w') { |f| f.print(backupper.backup_status.to_yaml) } 
end
