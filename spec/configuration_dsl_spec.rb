require 'spec_helper'
require 'configuration_dsl'

require 'backup_configuration'

shared_examples_for 'a dsl block checking for illegal entries' do
    it "reports name error" do
        begin
            dsl.configure(@configuration_item) do 
                blah
            end
        rescue ConfigurationSyntaxError => e
            e.message.should include("can't configure 'blah' in #{@block_name}")
        end
    end
end

describe MainDsl do 
    attr_reader :config
    
    before do
        @configuration_item = @config = BackupConfiguration.new
        @block_name = 'recipe'
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
        dsl.configure(config) do
            backup {}
        end
        config.backup.should_not be_nil
    end
    
    it_should_behave_like 'a dsl block checking for illegal entries'
    
    def dsl 
        MainDsl
    end
end

require 'backup'
describe BackupDsl do
    attr_reader :backup
    before do
        @configuration_item = @backup = Backup.new(nil)
        @block_name = 'backup'
    end
    
    it_should_behave_like 'a dsl block checking for illegal entries'
    
    def dsl 
        BackupDsl
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

describe DeliveryDsl do
    attr_reader :delivery 
    before do 
        @configuration_item = @delivery = Delivery.new
        @block_name = 'delivery'
    end
    
    it_should_behave_like 'a dsl block checking for illegal entries'
    
    def dsl 
        DeliveryDsl
    end
    
    describe 'configure son' do
        it "adds a son to delivery" do
            DeliveryDsl.configure(delivery) do
                son 
            end
            delivery.should create_a(:son)
        end
        it "can pass a name in configuration" do
            DeliveryDsl.configure(delivery) do
                son 'daily'
            end
            delivery.son.name.should == 'daily'
        end
        it "runs its configureation" do
            was_run = false
            DeliveryDsl.configure(delivery) do
                son 'daily' do
                    was_run = true
                end
            end
            was_run.should be_true
        end
    end
    
    describe 'configure father' do
        it "adds a father to delivery" do
            delivery = Delivery.new
            DeliveryDsl.configure(delivery) do
                father 
            end
            delivery.should create_a(:father)
        end
        it "can pass a name in configuration" do
            delivery = Delivery.new
            DeliveryDsl.configure(delivery) do
                father 'daily'
            end
            delivery.father.name.should == 'daily'
        end
        it "runs its configureation" do
            was_run = false
            DeliveryDsl.configure(delivery) do
                father 'weekley' do
                    was_run = true
                end
            end
            was_run.should be_true
        end
    end
    
    describe 'configure grandfather' do
        it "adds a father to delivery" do
            delivery = Delivery.new
            DeliveryDsl.configure(delivery) do
                grandfather
            end
            delivery.should create_a(:grandfather)
        end
        it "can pass a name in configuration" do
            delivery = Delivery.new
            DeliveryDsl.configure(delivery) do
                grandfather 'yearly'
            end
            delivery.grandfather.name.should == 'yearly'
        end
        it "runs its configureation" do
            was_run = false
            DeliveryDsl.configure(delivery) do
                grandfather 'weekley' do
                    was_run = true
                end
            end
            was_run.should be_true
        end
    end
end

describe BackupKindDsl do
    include Runt
    attr_reader :backup_kind
    before do
        @configuration_item = @backup_kind = BackupKind.new(:son, 'son')
        @block_name = 'son'
    end
    
    it_should_behave_like 'a dsl block checking for illegal entries'
    
    def dsl 
        BackupKindDsl
    end
    
    it "can configure the name in the block" do
        BackupKindDsl.configure(backup_kind) do
            name 'daily'
        end
        backup_kind.name.should == 'daily'
    end
    it "can configure the number of backups to keep" do
        BackupKindDsl.configure(backup_kind) do
            keep 31
        end
        backup_kind.number_to_keep.should == 31
    end
    
    it "can configure the day it should run" do
        BackupKindDsl.configure(backup_kind) do
            on_each last_friday
        end
        backup_kind.should_run_on?(Date.parse("30-07-2010")).should be_true
    end
    
    it "can use a customized runt expression for the day it should run" do
        BackupKindDsl.configure(backup_kind) do
            on_each Runt::REYear.new(1) & first_monday
        end
        backup_kind.should_run_on?(Date.parse("05-01-2009")).should be_true
    end

    it "can use a first_monday_in_january" do
        BackupKindDsl.configure(backup_kind) do
            on_each first_monday_in_january
        end
        backup_kind.should_run_on?(Date.parse("05-01-2009")).should be_true
        backup_kind.should_run_on?(Date.parse("02-02-2009")).should be_false
    end
    
end

require 'backup'
describe ArchiveDsl do 
    attr_reader :archive
    before do
        @configuration_item = @archive = Archive.new('some tar', nil)
        @block_name = 'some tar'
    end
    
    it_should_behave_like 'a dsl block checking for illegal entries'
    
    def dsl 
        ArchiveDsl
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
    
    it "can add a postgres_database" do
        ArchiveDsl.configure(archive) do
            postgres_database('database_name') { sudo_as 'gijs'}
        end
        archive.should have(1).commands
        postgres_dump = archive.commands.first
        postgres_dump.sudo_user.should == 'gijs'
    end
    
    it "can add a mysql_database" do
        ArchiveDsl.configure(archive) do
            mysql_database('database_name') { sudo_as 'gijs'}
        end
        archive.should have(1).commands
        mysql_dump = archive.commands.first
        mysql_dump.sudo_user.should == 'gijs'
    end
    
    it "can add a system command" do
        ArchiveDsl.configure(archive) do
            system_command('command_name') { run 'some_command'}
        end
        archive.should have(1).commands
        command = archive.commands.first
        command.should run('some_command')
    end

end

shared_examples_for 'abstract command dsl' do
    it_should_behave_like 'a dsl block checking for illegal entries'
    
    it "can configure a sudo user" do
        dsl.configure(command) do
            sudo_as 'gijs'
        end 
        command.sudo_user.should == 'gijs'
    end
end

shared_examples_for 'database dump dsl' do
    before do
        @block_name = dump.database_name
        @configuration_item = dump
    end

    it_should_behave_like 'abstract command dsl' 
    def command
        dump
    end
    it "has a name" do
        dump.database_name.should == 'database_name'
    end
    it "can configure extra options" do
        dsl.configure(dump) do
            extra_options '--blah'
        end 
        dump.extra_options.should == '--blah'
    end
    it "can configure overridden options" do
        dsl.configure(dump) do
            override_options '--blah'
        end 
        dump.options_override.should == '--blah'
    end
end

describe PostgresDumpDsl do
    it_should_behave_like 'database dump dsl'
    def dsl
        PostgresDumpDsl
    end
    def dump
        @dump ||= PostgresDump.new('database_name')
    end
    
end

describe MysqlDumpDsl do
    it_should_behave_like 'database dump dsl'

    it "can configure username and password" do
        dsl.configure(dump) do
            user 'harry'
            password 'secret'
        end 
        dump.username.should == 'harry'
        dump.password.should == 'secret'
    end

    def dsl
        MysqlDumpDsl
    end
    def dump
        @dump ||= MysqlDump.new('database_name')
    end
end

describe SystemCommandDsl do
    before do
        @configuration_item = command
        @block_name = command.name
    end
    it_should_behave_like 'abstract command dsl' 
    
    it "can configure a command_line" do
        dsl.configure(command) do
            run 'command_line'
        end 
        command.should run('command_line')
    end
    
    def dsl
        SystemCommandDsl
    end
    
    def command
        @command ||= SystemCommand.new('command_name')
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



