require 'spec_helper'
require 'archive'
require 'date_fmt'

describe Archive do
  include DateFmt
    
  describe 'run' do
    attr_reader :archive, :mock_delivery
    let(:date_override) { 'irrelevant date' }

    before do
      @mock_delivery = mock
      @archive = Archive.new('my_archive', mock_delivery, nil)
      @archive.destination = 'destination'
    end

    it "throws an exception when no files in archive" do
      mock_delivery.should_receive(:deliver).never
      lambda {
        run_archive
      }.should raise_exception IllegalArchiveException
    end
    
    it "throws no destination in archive" do
      archive.add_file 'filename1'
      archive.destination = nil
      mock_delivery.should_receive(:deliver).never
      lambda {
        run_archive 
      }.should raise_exception IllegalArchiveException
    end
    
    it "delivers itself to the delivery if archive contains files" do
      archive.add_file 'filename1'
      mock_delivery.should_receive(:deliver).with(archive)
      run_archive
    end

    it "delivers itself to the delivery if archive contains commands" do
      archive.add_command('some command')
      mock_delivery.should_receive(:deliver).with(archive)
      run_archive
    end

    it "overrides the run_date for late use" do
      archive.run_date.should == Date.today
      archive.add_file 'filename1'
      mock_delivery.stub :deliver
      run_archive
      archive.run_date.should == date_override
    end

    def run_archive
      archive.run(date_override)
    end
  end

  describe 'create an archive' do
    attr_reader :archive, :working_file, :shell_runner
    let(:running_on) { Date.parse('2010-03-19') }
    before do
      @shell_runner = mock 'shell_runner'
      @archive = Archive.new('my_archive', nil, shell_runner, running_on)
      archive.add_file 'filename1'
      archive.destination = '/some/directory'
      @working_file = "my_archive_daily_#{running_on.as_string}.tgz"
    end
    
    it "runs a tar command and sends it to output directory" do
      shell_runner.should_receive(:run_command).with("tar cvzf #{working_file} filename1")
      shell_runner.should_receive(:move).with(working_file, '/some/directory/')
      archive.create 'daily'
    end    
    
    it "runs a tar command using multiple input files sending it to the output directory" do
      archive.add_file 'filename2'
      shell_runner.should_receive(:run_command).with("tar cvzf #{working_file} filename1 filename2")
      shell_runner.should_receive(:move).with(working_file, '/some/directory/')
      archive.create 'daily' 
    end
    
    it "resulting filename contains the backup_kind in it" do
      expected_working_file = "my_archive_backupkind_#{running_on.as_string}.tgz"
      shell_runner.should_receive(:run_command).with("tar cvzf #{expected_working_file} filename1")
      shell_runner.should_receive(:move).with(expected_working_file, '/some/directory/')
      archive.create 'backupkind'
    end    

    describe "with commands" do
      attr_reader :command
      before do 
        @command = mock 'command'
        archive.add_command command
        shell_runner.stub!(:move) # tested above
      end
      
      it "adds a result of a command to the tar" do
        command.should_receive(:run).and_return 'command_result.txt'
        shell_runner.should_receive(:run_command).with("tar cvzf #{working_file} filename1 command_result.txt")
        archive.create 'daily'
      end
      
      it "supports more commands in archive" do
        command2 = mock 'command'
        archive.add_command(command2)
        command.should_receive(:run).and_return('command_result.txt')
        command2.should_receive(:run).and_return('command_result2.txt')
        shell_runner.should_receive(:run_command).with("tar cvzf #{working_file} filename1 command_result.txt command_result2.txt")
        archive.create 'daily'
      end
    end   
  end

  describe 'exists?' do
    attr_reader :archive, :working_file, :shell_runner
    before do
      @shell_runner = mock 'shell_runner'
      @archive = Archive.new('my_archive', nil, shell_runner)
      @archive.destination = 'destination'
    end
    
    it "is true when one or more files exist of the archive name and kind" do
      shell_runner.should_receive(:exists?).with('destination/my_archive_son*').and_return true
      archive.exists?('son').should be_true
    end
    it "is false when no files exist of the archive name and kind" do
      shell_runner.should_receive(:exists?).with('destination/my_archive_son*').and_return false
      archive.exists?('son').should be_false
    end
  end
  
  describe 'remove_exceeding' do
    attr_reader :archive, :working_file, :shell_runner
    before do
      @shell_runner = mock 'shell_runner'
      @archive = Archive.new('my_archive', nil, shell_runner)
      @archive.destination = 'destination'
    end
    
    it "should remove exceeding archives" do
      shell_runner.should_receive(:ordered_list).with('destination/my_archive_son*').and_return ['file1', 'file2', 'file3']
      shell_runner.should_receive(:rm).with('file1')
      shell_runner.should_receive(:rm).with('file2')
      archive.remove_exceeding('son', 1)
    end
  end
   
end
