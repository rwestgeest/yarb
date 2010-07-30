require 'archive'

describe Archive do
    it "can add a file"
    it "can add more files at once"
        
    describe 'run' do
        attr_reader :archive, :mock_shell_runner, :mock_delivery
        
        before do
            @mock_delivery = mock
            @mock_shell_runner = mock
            @archive = Archive.new('my_archive', mock_shell_runner)
            archive.add_file 'filename1'
            archive.destination = '/some/directory'
        end
        
        it "runs a tar command using one input file sending it to the output file" do
            mock_shell_runner.should_receive(:run_command).with('tar cvzf /tmp/yarb/my_archive.tgz filename1')
            mock_delivery.should_receive(:deliver).with('/tmp/yarb/my_archive.tgz', '/some/directory')
            archive.run mock_delivery
        end
        
        it "runs a tar command using multiple input files sending it to the output file" do
            archive.add_file 'filename2'
            mock_shell_runner.should_receive(:run_command).with('tar cvzf /tmp/yarb/my_archive.tgz filename1 filename2')
            mock_delivery.should_receive(:deliver).with('/tmp/yarb/my_archive.tgz', '/some/directory')
            archive.run mock_delivery
        end
    end
end