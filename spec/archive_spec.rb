require 'archive'

describe Archive do
        
    describe 'run' do
        attr_reader :archive, :mock_shell_runner, :mock_delivery, :generated_filepath
        
        before do
            @mock_delivery = mock
            @mock_shell_runner = mock
            @archive = Archive.new('my_archive', mock_delivery, mock_shell_runner)
            archive.add_file 'filename1'
            archive.destination = '/some/directory'
            mock_delivery.stub!(:target_filename).with('my_archive').and_return('generated_filename')            
            @generated_filepath = '/tmp/yarb/generated_filename.tgz'
        end
        
        it "runs a tar command using one input file sending it to the output directory" do
            mock_shell_runner.should_receive(:run_command).with("tar cvzf #{generated_filepath} filename1")
            mock_delivery.should_receive(:deliver).with(generated_filepath, '/some/directory')
            archive.run 
        end
        
        it "runs a tar command using multiple input files sending it to the output directory" do
            archive.add_file 'filename2'
            mock_shell_runner.should_receive(:run_command).with("tar cvzf #{generated_filepath} filename1 filename2")
            mock_delivery.should_receive(:deliver).with(generated_filepath, '/some/directory')
            archive.run 
        end
    end
end
