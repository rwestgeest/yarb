require 'spec_helper'
require 'fileutils'
require 'backup_configuration'
require 'date_fmt'
include FileUtils

describe 'backups' do
  include DateFmt
  def tar_list(name, run_on = Date.today)
    expected_tar = output_file "destination/#{name}_#{run_on.strftime('%Y-%m-%d')}.tgz"
    return 'output tar not present' unless File.exists?(expected_tar)
    `tar tvzf #{expected_tar}`
  end

  def run_backup recipe_file
    command = "#{File.join(PROJECT_ROOT, 'bin', 'yarb')} "
    command << "--recipe #{File.join(File.dirname(__FILE__),recipe_file)} "
    command << ">> /dev/null"
    system command
  end

  def test_backup recipe_file, run_date = nil
    command = "#{File.join(PROJECT_ROOT, 'bin', 'yarb')} --test "
    command << "#{run_date} " if run_date
    command << "--recipe #{File.join(File.dirname(__FILE__),recipe_file)}"
    `#{command}`
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

  it "can show what it does in test mode" do
    result = test_backup 'simple_directory_archive.recipe'
    result.should include('tar cvzf simple_tar_daily')
    result.should include('moving simple_tar_daily')
  end

  it "can specify a date for testing" do
    the_date = Date.parse('19-03-2010')
    result = test_backup 'simple_directory_archive.recipe', the_date.strftime('%d-%m-%Y')
    result.should include("tar cvzf simple_tar_daily_#{the_date.as_string}")
    result.should include("moving simple_tar_daily_#{the_date.as_string}")
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

  describe 'with custom command' do
    it "can include the result of a custom command in the archive" do
      result = run_backup 'directory_with_custom_command_archive.recipe'
      result.should be_true, 'backup should be succesful'
      tar_list('simple_tar_daily').should include 'mydir/file1'
      tar_list('simple_tar_daily').should include 'my_command.out'
    end
  end

  describe 'fairly standard gfs specification year month day' do
    let(:recipe) { 'typical_gfs.recipe' }

    it "runs yearly backup on first sunday in year" do
      the_date = Date.parse("02-01-2011")
      result = test_backup recipe, the_date.strftime('%d-%m-%Y')
      result.should include("tar cvzf simple_tar_yearly_#{the_date.as_string}")
    end
    it "runs monthly backup on first sunday of any other month" do
      the_date = Date.parse("06-03-2011")
      create_output_file('destination/simple_tar_yearly_2011-01-02.tgz')
      result = test_backup recipe, the_date.strftime('%d-%m-%Y')
      result.should include("tar cvzf simple_tar_monthly_#{the_date.as_string}")
    end
    it "runs daily backup on other days" do
      the_date = Date.parse("07-03-2011")
      create_output_file('destination/simple_tar_yearly_2011-01-02.tgz')
      create_output_file('destination/simple_tar_monthly_2011-03-06.tgz')
      result = test_backup recipe, the_date.strftime('%d-%m-%Y')
      result.should include("tar cvzf simple_tar_daily_#{the_date.as_string}")
    end
  end
end
