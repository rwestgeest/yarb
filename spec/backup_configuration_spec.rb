require 'spec_helper'
require 'backup_configuration'
require 'mail_message'

describe BackupConfiguration do
    
    describe 'building a backup' do
        it "can ad an archive to the backup" do
            config = BackupConfiguration.from_string %Q{
                backup do 
                    archive('simple_tar') {} 
                end
            }
            
            config.backup.should have(1).archives
        end
        
        it "can configure an email" do
            config = BackupConfiguration.from_string %Q{
                mail do 
                    success_mail 
                end
            }
            
            config.mail(:success_mail).should be_a(MailMessage)
        end

        describe 'complete archive specification' do
            it "builds a backup from an achive specification" do
                File.should_receive(:read).with('filename').and_return %Q{
                    backup do 
                        archive 'simple_tar' do
                            file 'some_dir'
                            destination 'output_data' 
                        end
                    end
                }
                config = BackupConfiguration.from_file 'filename', nil
                
                backup = config.backup
                
                backup.should have(1).archives
            end
        end
    end
    
    describe 'errors in specification' do
        it "reports a syntax error" do
            begin
                config = BackupConfiguration.from_string %Q{
                    backup do 
                        end
                    end
                }, 'source_file'
            rescue ConfigurationSyntaxError => e
                e.message.should include('source_file') 
                e.message.should include('syntax error')
            end
        end
        it "reports name error" do
            begin
                config = BackupConfiguration.from_string %Q{
                    backup do 
                        blah
                    end
                }, 'source_file'
            rescue ConfigurationSyntaxError => e
                puts e
                e.message.should include('source_file') 
                e.message.should include('blah')
            end
        end

    end

end

