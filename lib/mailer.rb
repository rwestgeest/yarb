require 'net/smtp'
require 'erb'
require 'ostruct'

class Mailer 
    TemplateLocation = '/etc/backup/'
    def self.from_spec(mail_spec = {})
        Mailer.new(mail_spec)
    end 
    def initialize(mail_spec = {})
        @mail_spec = {:subject => 'no_subject' , 
                                 :message => 'no_message', 
                                 :template => 'no_template', 
                                 :receipient => 'no_receipient'}.merge(mail_spec)
        @mail_spec = mail_spec
    end
    def deliver 
        erb = ERB.new(File.read(TemplateLocation+@mail_spec[:template]))
        @mail_spec[:message] = erb.result(OpenStruct.new(@mail_spec).send('binding'))
        @mail_spec[:date] = Time.now.to_s
        do_send
    end
    
    private 
    def do_send
#        puts "sending mail based on mailspec: #{@mail_spec.inspect}"
        Net::SMTP.start(@mail_spec[:smtp_server]) do |smtp| 
            smtp.sendmail(@mail_spec[:message], @mail_spec[:from_email_address], @mail_spec[:recepient])
        end
    end
end

