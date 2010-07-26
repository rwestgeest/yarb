require 'spec_helper'
require 'reporter'

describe Reporter do
    attr_reader :mailed, :mail_was_sent
    attr_accessor :reporter
    
    def deliver
        @mail_was_sent = true
    end
    def from_spec(mailer_spec)
        @mailed[mailer_spec[:recepient]] =  mailer_spec
        self
    end
    def not_mailed(recepient)
        !mailed.has_key? recepient
    end
    before do 
        @mailed = {}
        @logger = stub.as_null_object
        self.reporter = Reporter.new(self, @logger)
    end

    it 'evaluates recepients from configuration file' do
        File.should_receive(:read).with('some_file').and_return <<END_OF_SPEC
        # this is a recepient configuration        
        on :success, :recepient => 'some@mail.address', :template => 'some_mail_template'
        on :success, :recepient => 'other@mail.address', :template => 'some_mail_template'
        on :failure, :recepient => 'other@mail.address', :template => 'other_mail_template'
END_OF_SPEC

        reporter = Reporter.from_configuration_file('some_file', self, @logger)
        reporter.mailer_specs(:success).should == [{:recepient => 'some@mail.address', :template => 'some_mail_template'},
                                                   {:recepient => 'other@mail.address', :template => 'some_mail_template'}]
        reporter.mailer_specs(:failure).should == [{:recepient => 'other@mail.address', :template => 'other_mail_template'}]
    end
    
    it 'can set from_mail on reporter' do
        reporter.add_recepient :success, :recepient => 'r1@mail.com', :template => 'success.rmail'
        reporter.add_recepient :success, :recepient => 'r2@mail.com', :template => 'success.rmail'
        reporter.set :from_email_address , "blah"
        reporter.report("backup")
        
         mailed['r1@mail.com'][:from_email_address].should == 'blah'
         mailed['r2@mail.com'][:from_email_address].should == 'blah'
    end
    
    it 'can set smtp_server on reporter' do
        reporter.add_recepient :success, :recepient => 'r1@mail.com', :template => 'success.rmail'
        reporter.add_recepient :success, :recepient => 'r2@mail.com', :template => 'success.rmail'
        reporter.set :smtp_server, "smtp"
        reporter.report("backup")
        
         mailed['r1@mail.com'][:smtp_server].should == 'smtp'
         mailed['r2@mail.com'][:smtp_server].should == 'smtp'
    end
        
    it 'sends only info messages result in normal report' do
        reporter.add_recepient :success, :recepient => 'r1@mail.com', :template => 'success.rmail'
        
        reporter.info "done something"
        reporter.notify_action "take out tape"

        reporter.report("backup")
        mail_was_sent.should == true
        mailed['r1@mail.com'][:template].should == 'success.rmail'
        mailed['r1@mail.com'][:subject].should == 'Success: backup'
        mailed['r1@mail.com'][:recepient].should == 'r1@mail.com'
        mailed['r1@mail.com'][:log].should be_include('done something')
        mailed['r1@mail.com'][:actions].should be_include('take out tape')
    end

    it 'sends error messages result in error report' do
        reporter.add_recepient :success, :recepient => 'notified_on_success', :template => 'success.rmail'
        reporter.add_recepient :failure, :recepient => 'r1@mail.com', :template => 'error.rmail'
        
        reporter.info "done something good"
        reporter.error "done something wrong"
        reporter.notify_action "check logs"

        reporter.report("backup")
        mail_was_sent.should == true
        mailed['r1@mail.com'].should_not be_nil
        mailed['r1@mail.com'][:subject].should == 'Failure: backup'
        not_mailed('notified_on_success').should_not be_nil
    end

    it 'multiple receipients can get the same message' do
        reporter.add_recepient :success, :recepient => 'r1@mail.com', :template => 'success.rmail'
        reporter.add_recepient :success, :recepient => 'r2@mail.com', :template => 'success.rmail'
        reporter.report("backup")
         mailed['r1@mail.com'][:template].should == 'success.rmail'
         mailed['r2@mail.com'][:template].should == 'success.rmail'
         mailed['r1@mail.com'][:recepient].should == 'r1@mail.com'
         mailed['r2@mail.com'][:recepient].should == 'r2@mail.com'
    end

end

