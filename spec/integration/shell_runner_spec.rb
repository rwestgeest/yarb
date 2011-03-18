require 'spec_helper'
require 'shell_runner'

describe ShellRunner do
  attr_reader :shell_runner
  before do
    @shell_runner = ShellRunner.new
  end

  describe "run_command" do
    it "can run a command" do
      shell_runner.run_command('ls').should == true
    end

    it "fails if the command fails" do
      shell_runner.run_command('rm garbledigook').should == false
    end
  end

  describe "move" do
    before do
      clean_input
      clean_output
    end

    after do
      clean_input
      clean_output
    end

    it "moves the file from source to destination file" do
      create_input_file 'source_file'
      shell_runner.move(input_file('source_file'),output_file('destination/dest_file'))
      File.should exist(output_file('destination/dest_file'))
    end
    it "moves the file from source to destination dir" do
      create_input_file 'source_file'
      shell_runner.move(input_file('source_file'),output_file('destination/'))
      File.should exist(output_file('destination/source_file'))
    end
  end

  describe "rm" do
    it "removes a file" do
      create_input_file 'the_file'
      File.should exist(input_file('the_file'))
      shell_runner.rm input_file('the_file')
      File.should_not exist(input_file('the_file'))
    end
  end

  describe "ordered_list" do
    before do
      clean_input
      create_input_file 'dir/the_file2'
      create_input_file 'dir/the_file1'
      create_input_file 'dir/another_file'
    end

    it "returns a alphabetically ordered directory listing" do
      list = shell_runner.ordered_list input_file('dir')
      list.should == [input_file('dir/another_file'), input_file('dir/the_file1'), input_file('dir/the_file2')]
    end

    it "returns a alphabetically ordered directory for a pattern" do
      list = shell_runner.ordered_list input_file('dir/the*')
      list.should == [input_file('dir/the_file1'), input_file('dir/the_file2')]
    end
  end

  describe "exists?(path)" do
    before do
      clean_input
    end

    it "returns false it the input is empty" do
      shell_runner.exists?(input_file('*')).should be_false
    end

    it "returns true if the file exists" do
      create_input_file('blah.txt')
      shell_runner.exists?(input_file('blah.txt')).should be_true
    end

    it "returns true if some file exists in wild card" do
      create_input_file('blah.txt')
      shell_runner.exists?(input_file('blah*')).should be_true
    end
    it "returns false if othing exists in wild card" do
      create_input_file('blah.txt')
      shell_runner.exists?(input_file('bloh*')).should be_false
    end
  end
end
