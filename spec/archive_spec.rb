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
            mock_delivery.stub!(:working_archive_file).with('my_archive').and_return('generated_filename.tgz')            
            @generated_filepath = 'generated_filename.tgz'
        end
        
        it "runs a tar command using one input file sending it to the output directory" do
            mock_shell_runner.should_receive(:run_command).with("tar cvzf #{generated_filepath} filename1")
            mock_delivery.should_receive(:deliver).with('my_archive', '/some/directory')
            archive.run 
        end
        
        it "runs a tar command using multiple input files sending it to the output directory" do
            archive.add_file 'filename2'
            mock_shell_runner.should_receive(:run_command).with("tar cvzf #{generated_filepath} filename1 filename2")
            mock_delivery.should_receive(:deliver).with('my_archive', '/some/directory')
            archive.run 
        end
     
        describe "with commands" do
            attr_reader :command
            before do 
                @command = mock 'command'
                archive.add_command command
                mock_delivery.stub!(:deliver) # tested above
            end
            
            it "adds a result of a command to the tar" do
                command.should_receive(:run).and_return 'command_result.txt'
                mock_shell_runner.should_receive(:run_command).with("tar cvzf #{generated_filepath} filename1 command_result.txt")
                archive.run 
            end
            
            it "supports more commands in this" do
                command2 = mock 'command'
                archive.add_command(command2)
                command.should_receive(:run).and_return('command_result.txt')
                command2.should_receive(:run).and_return('command_result2.txt')
                mock_shell_runner.should_receive(:run_command).with("tar cvzf #{generated_filepath} filename1 command_result.txt command_result2.txt")
                archive.run 
            end
        end   
    end
    
end
