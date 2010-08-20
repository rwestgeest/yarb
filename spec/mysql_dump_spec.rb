require 'spec_helper'
require 'mysql_dump'

describe MysqlDump do
    attr_reader :mysql_dump, :shell_runner
    
    before do
        @shell_runner = mock 'shell'
        @mysql_dump = MysqlDump.new 'database_name', shell_runner
    end
    
    describe 'run' do
        it "runs a dump command" do
            shell_runner.should_receive(:run_command).with('mysqldump database_name > database_name_mysql.dump')
            mysql_dump.run 
        end
       
        it "uses sudo if sudo user was configured" do
            mysql_dump.sudo_as_user 'some_user' 
            shell_runner.should_receive(:run_command).with('sudo -u some_user mysqldump database_name > database_name_mysql.dump')
            mysql_dump.run
        end
        
        it "uses username if configured" do
            mysql_dump.username = 'some_user' 
            shell_runner.should_receive(:run_command).with('mysqldump -u some_user database_name > database_name_mysql.dump')
            mysql_dump.run
        end
        
        it "uses username and password if configured" do
            mysql_dump.username = 'some_user' 
            mysql_dump.password = 'some_pass' 
            shell_runner.should_receive(:run_command).with('mysqldump -u some_user --password=some_pass database_name > database_name_mysql.dump')
            mysql_dump.run
        end
        
        it "accepts overridden options" do
            mysql_dump.username = 'some_user' 
            mysql_dump.options_override = "--some_options"
            shell_runner.should_receive(:run_command).with('mysqldump --some_options database_name > database_name_mysql.dump')
            mysql_dump.run
        end
        
        it "accepts extra options" do
            mysql_dump.username = 'some_user' 
            mysql_dump.extra_options = "--some_options"
            shell_runner.should_receive(:run_command).with('mysqldump -u some_user --some_options database_name > database_name_mysql.dump')
            mysql_dump.run
        end
                     
        it "returns the resulting filename" do
            shell_runner.stub(:run_command)
            mysql_dump.run.should == 'database_name_mysql.dump' 
        end   
    end
        
end
