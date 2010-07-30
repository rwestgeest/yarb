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
    it "can add a an archive" do
        backup = Backup.new
        BackupDsl.configure(backup) do
            archive('simple tar') {}
        end
        backup.should have(1).archives
        backup.archives.first.name.should == 'simple tar' 
    end
end

require 'backup'
describe ArchiveDsl do 
    it "has no files initially" do
        archive = Archive.new 'some tar'
        ArchiveDsl.configure(archive) do
        end
        archive.should have(0).files
    end

    it "can add a file to the archive" do
        archive = Archive.new 'some tar'
        ArchiveDsl.configure(archive) do
            file 'some file'
        end
        archive.should have(1).files
        archive.files[0].should == 'some file' 
    end
    
    it "can set the destination for the archive" do
        archive = Archive.new 'some tar'
        ArchiveDsl.configure(archive) do
            destination 'some dir'
        end
        archive.destination.should == 'some dir'
    end

end

require 'mail_message'
describe MailDsl do 
    it "can add a mail message" do
        config = MailConfiguration.new
        MailDsl.configure(config) do
            success_mail 
        end
        config.mail(:success_mail).should be_a(MailMessage)
    end
end



