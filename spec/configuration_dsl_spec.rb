require 'spec_helper'
require 'configuration_dsl'

require 'backup_configuration'
describe MainDsl do 
    attr_reader :config
    
    before do
        @config = BackupConfiguration.new
    end    
    
    it "has no backup nor mail initially" do 
        config.backup.should be_nil
        
        begin
            config.mail(:success_mail)
            fail('MailNotDefinedException expected')
        rescue MailNotDefinedException
        end
            
    end
    
    it "can add a backup to the configuration" do
        MainDsl.configure(config) do
            backup {}
        end
        config.backup.should_not be_nil
    end
end

require 'backup'
describe BackupDsl do
    attr_reader :backup
    before do
        @backup = Backup.new nil
        
    end
    
    describe "adding an archive" do
        before do
            BackupDsl.configure(backup) do
                archive('simple tar') {}
            end
        end
        
        it "adds the archive to the backup" do
            backup.should have(1).archives
            backup.archives.first.name.should == 'simple tar' 
        end
        
        it "uses the backups delivery as delivery" do
            backup.archives.first.delivery.should == backup.delivery
        end
    end
    
    describe "defining the delivery strategy" do
        it "sets the delivery on the backup" do
            BackupDsl.configure(backup) do
                delivery {}
            end
            backup.delivery.should_not be_nil
        end
        
        it "can configure a son" do
            BackupDsl.configure(backup) do
                delivery do 
                    son
                end
            end
            backup.delivery.should create_a(:son)
        end
    end
end

require 'backup'
describe ArchiveDsl do 
    attr_reader :archive
    before do
        @archive = Archive.new 'some tar', nil
    end
    it "has no files initially" do
        ArchiveDsl.configure(archive) do
        end
        archive.should have(0).files
    end

    it "can add a file to the archive" do
        ArchiveDsl.configure(archive) do
            file 'some file'
        end
        archive.should have(1).files
        archive.files[0].should == 'some file' 
    end
    
    it "can add more files to the archive" do
        ArchiveDsl.configure(archive) do
            file 'some file'
            file 'someother_file'
        end
        archive.files.should include('some file')
        archive.files.should include('someother_file')
    end
    
    it "can add a filelist to the archive" do
        ArchiveDsl.configure(archive) do
            files 'some file', 'someother_file'
        end
        archive.files.should include('some file')
        archive.files.should include('someother_file')
    end
    
    it "can set the destination for the archive" do
        ArchiveDsl.configure(archive) do
            destination 'some dir'
        end
        archive.destination.should == 'some dir'
    end

end

require 'mail_message'
describe MailDsl do 
    attr_reader :config
    before do
        @config = MailConfiguration.new
    end
    it "can add a mail message" do
        MailDsl.configure(config) do
            success_mail {}
        end
        config.mail(:success_mail).should be_a(MailMessage)
    end
    it "can add a more messages message" do
        MailDsl.configure(config) do
            success_mail {}
            error_mail {} 
        end
        config.mail(:success_mail).should be_a(MailMessage)
        config.mail(:error_mail).should be_a(MailMessage)
    end
end

describe "configuring a mail" do
    it "can define a from address"
    it "can define a to address list"
    it "can define a subject"
    it "can define a text"
    it "can includ a log"
end



