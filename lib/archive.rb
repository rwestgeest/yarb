require 'shell_runner'
require 'date_fmt'

class IllegalArchiveException < Exception
end 

class Archive
  include DateFmt
  
  attr_reader :files, :name, :delivery, :commands, :run_date
  attr_accessor :destination
  def initialize(name, delivery, shell_runner, run_date = Date.today)
    @name = name
    @delivery = delivery
    @files = []
    @commands = []
    @shell_runner = shell_runner
    @run_date = run_date
  end
  
  def add_file(filename)
    @files << filename
  end
  
  def add_files(*filenames)
    @files += filenames
  end
  
  def create_command(command_class, name)
    command = command_class.new(name, @shell_runner)
    add_command command
    return command
  end
  
  def add_command(command)
    @commands << command
  end
  
  def run(date_override)
    @run_date = date_override
    if (files.empty? and commands.empty?) or destination.nil?
      raise IllegalArchiveException.new("archive #{name} is empty") 
    end
    @delivery.deliver(self)
  end
  
  def create kind_of_backup
    @files += commands.collect { |command| command.run } 
    @shell_runner.run_command(tar_command(kind_of_backup))
    @shell_runner.move(tar(kind_of_backup), destination + '/')
  end  
  
  def remove_exceeding kind_of_backup, number_to_keep
    filelist = @shell_runner.ordered_list(backup_file_pattern(kind_of_backup))
    while (filelist.length > number_to_keep) 
      @shell_runner.rm(filelist.shift)
    end
  end
  
  def exists?(kind_of_backup)
    result = @shell_runner.exists?(backup_file_pattern(kind_of_backup))
    puts "#{kind_of_backup} exists? #{result}"
    result 
  end
  
  private 
  def tar_command(kind_of_backup)
    "tar cvzf #{tar(kind_of_backup)} #{input_files}"
  end
  
  def tar(kind_of_backup)
    "#{basename(kind_of_backup)}_#{run_date.as_string}.tgz"
  end
  
  def backup_file_pattern(kind_of_backup)
    "#{destination}/#{basename(kind_of_backup)}*"
  end
  
  def basename(kind_of_backup)
    "#{name}_#{kind_of_backup}"
  end
  
  def input_files
    files.flatten.join(' ')
  end
end

