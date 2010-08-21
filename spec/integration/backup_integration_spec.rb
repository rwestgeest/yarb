require 'spec_helper'
require 'fileutils'
require 'backup_configuration'
include FileUtils

describe 'backups' do
    
    def tar_list(name)
        expected_tar = output_file "destination/#{name}_#{Date.today.strftime('%Y-%m-%d')}.tgz"
        return 'output tar not present' unless File.exists?(expected_tar)
        `tar tvzf #{expected_tar}`
    end
        
    def run_backup recipe_file
        system "#{File.join(PROJECT_ROOT, 'bin', 'yarb')} --recipe #{File.join(File.dirname(__FILE__),recipe_file)} >> /dev/null"
    end
        
    def test_backup recipe_file
        `#{File.join(PROJECT_ROOT, 'bin', 'yarb')} --test --recipe #{File.join(File.dirname(__FILE__),recipe_file)}`
    end    
    
    before do
        clean_input
        clean_output
        create_input_file 'mydir/file1' 
        create_input_file 'mydir/file2' 
    end
    
    after do
        clean_input
        clean_output
    end
    
    it "can make a simple directory backup" do
        result = run_backup 'simple_directory_archive.recipe'
        result.should be_true, 'backup should be succesful'
        tar_list('simple_tar_daily').should include 'mydir/file1' 
        tar_list('simple_tar_daily').should include 'mydir/file2' 
    end

    it "can show what it does" do
        result = test_backup 'simple_directory_archive.recipe'
        result.should include('tar cvzf simple_tar_daily')
        result.should include('moving simple_tar_daily')
    end
    
    it "can make two simple directory backups" do
        result = run_backup 'two_simple_directory_archive.recipe'
        result.should be_true, 'backup should be succesful'
        tar_list('first_tar_daily').should include 'mydir/file1' 
        tar_list('second_tar_daily').should include 'mydir/file2' 
    end
    
    it "will make yearly first, then monthly, then daily" do
        run_backup('simple_gfs_archive.recipe').should be_true, 'backup should be successful'
        tar_list('simple_tar_yearly').should include 'mydir/file1' 
        tar_list('simple_tar_weekly').should == 'output tar not present'
        tar_list('simple_tar_daily').should == 'output tar not present'

        run_backup('simple_gfs_archive.recipe').should be_true, 'backup should be successful'
        tar_list('simple_tar_yearly').should include 'mydir/file1' 
        tar_list('simple_tar_weekly').should include 'mydir/file1' 
        tar_list('simple_tar_daily').should == 'output tar not present'

        run_backup('simple_gfs_archive.recipe').should be_true, 'backup should be successful'
        tar_list('simple_tar_yearly').should include 'mydir/file1' 
        tar_list('simple_tar_weekly').should include 'mydir/file1' 
        tar_list('simple_tar_daily').should include 'mydir/file1' 
    end

    describe 'with postgres database' do
        it "can include a postgres dump in the archive" do
            pending "you might not want to create a postgres database - enable this spec if you do"
            system('sudo -u postgres createdb my_yarb_database')
            result = run_backup 'directory_with_postgres_dump_archive.recipe'
            result.should be_true, 'backup should be succesful'
            tar_list('simple_tar_daily').should include 'mydir/file1' 
            tar_list('simple_tar_daily').should include 'my_yarb_database_postgres.dump' 
            system('sudo -u postgres dropdb my_yarb_database')
        end
    end
    
    describe 'with mysql database' do
        it "can include a mysql dump in the archive" do
            pending "you might not want to create a mysql database - enable this spec if you do"
            system('mysqladmin -u root --password=stoomboot create my_yarb_database')
            result = run_backup 'directory_with_mysql_dump_archive.recipe'
            result.should be_true, 'backup should be succesful'
            tar_list('simple_tar_daily').should include 'mydir/file1' 
            tar_list('simple_tar_daily').should include 'my_yarb_database_mysql.dump' 
            system('mysqladmin -f -u root --password=stoomboot drop my_yarb_database')
        end
    end

    describe 'with cusom command' do
        it "can include the result of a custom command in the archive" do
            result = run_backup 'directory_with_custom_command_archive.recipe'
            result.should be_true, 'backup should be succesful'
            tar_list('simple_tar_daily').should include 'mydir/file1' 
            tar_list('simple_tar_daily').should include 'my_command.out' 
        end
    end

end
