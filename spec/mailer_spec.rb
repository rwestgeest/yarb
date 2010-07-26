require 'spec_helper'
require 'mailer'
class Mailer 
    def sent_message
        @sent_mail
    end
    def do_send
        @sent_mail = @mail_spec
    end
end

describe Mailer do
    it '_send_mail_on_template' do
        File.should_receive(:read).with('/etc/backup/template_name').and_return "template_string"
        
        mailer = Mailer.from_spec(:template => "template_name",
                                            :receipient => 'mail.com',
                                            :subject => 'subject')
        mailer.deliver
        mailer.sent_message[:subject].should == 'subject'
        mailer.sent_message[:message].should == 'template_string'
        mailer.sent_message[:receipient].should == 'mail.com'
    end

    it '_template_is_erbed' do
        File.should_receive(:read).and_return "template_<%= some_variable %> string"
        mailer = Mailer.from_spec(:template => "template_name",
                                            :receipient => 'mail.com',
                                            :subject => 'subject',
                                            :some_variable => 'stupid')
        mailer.deliver
        mailer.sent_message[:message].should == 'template_stupid string'
    end
end

