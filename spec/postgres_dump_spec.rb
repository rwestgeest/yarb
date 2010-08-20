require 'spec_helper'
require 'postgres_dump'

describe PostgresDump do
    attr_reader :postgres_dump, :shell_runner
    
    before do
        @shell_runner = mock 'shell'
        @postgres_dump = PostgresDump.new 'database_name', shell_runner
    end
    
    describe 'run' do
        it "runs a dump command" do
            shell_runner.should_receive(:run_command).with('pg_dump --no-acl database_name > database_name_postgres.dump')
            postgres_dump.run 
        end
       
        it "uses sudo if sudo user was configured" do
            postgres_dump.sudo_as_user 'some_user' 
            shell_runner.should_receive(:run_command).with('sudo -u some_user pg_dump --no-acl database_name > database_name_postgres.dump')
            postgres_dump.run
        end
        
        it "accepts overridden options" do
            postgres_dump.options_override = "--some_options"
            shell_runner.should_receive(:run_command).with('pg_dump --some_options database_name > database_name_postgres.dump')
            postgres_dump.run
        end
        
        it "accepts extra options" do
            postgres_dump.extra_options = "--some_options"
            shell_runner.should_receive(:run_command).with('pg_dump --no-acl --some_options database_name > database_name_postgres.dump')
            postgres_dump.run
        end

        
            
        it "returns the resulting filename" do
            shell_runner.stub(:run_command)
            postgres_dump.run.should == 'database_name_postgres.dump' 
        end 
        
          
    end
        
end
