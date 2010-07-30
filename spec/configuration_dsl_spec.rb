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



