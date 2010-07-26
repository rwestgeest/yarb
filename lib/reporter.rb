require 'mailer'

class Reporter
    LogFile = '/var/log/backup.log'
    ConfigurationFile = '/etc/backup/recepients.rb'
    attr_accessor :email_address, :smtp_server
    
    def self.from_configuration_file(configuration_file = ConfigurationFile, mailer = Mailer, logger = Logger.new(LogFile, 'monthly'))
        reporter = Reporter.new(mailer, logger)
        reporter.load_recepients(File.read(configuration_file))
        reporter
    end
    
    def initialize(mailer_factory, logger)
        @mailer_factory = mailer_factory
        @mailer_specs = {}
        @log = []
        @actions = []
        @errors = []
        @logger = logger
        @basic_config = {}
    end
    
    def set(variable, value)
        @basic_config[variable] = value
    end
    def load_recepients(configuration)
        instance_eval configuration
    end
    
    def mailer_specs(in_case_of)
        @mailer_specs[in_case_of] = [] unless @mailer_specs[in_case_of]
        @mailer_specs[in_case_of]
    end
    
    def add_recepient(in_case_of, recepient_spec = {})
        mailer_specs(in_case_of) << recepient_spec
    end
    alias_method :on,:add_recepient
    
    def info(message)
        @log << message
        @logger.info message
    end
    
    def error(message)
        @errors << "error: "+ message
        @log << "error: "+message
        @logger.info message
    end
    
    def log
        @log.join("\n")
    end
    
    def actions 
        @actions.collect{|action| "* #{action}"}.join(";\n")
    end
    
    def notify_action(action)
        @actions << action
    end
    
    def report(subject)
        in_case_of = :success 
        in_case_of = :failure unless @errors.empty?
        mailer_specs(in_case_of).each do |mailer_spec|
            @mailer_factory.from_spec(mailer_spec.merge(:subject => in_case_of.to_s.capitalize + ': '+ subject, 
                                                                                        :log => log,
                                                                                        :actions => actions).merge(@basic_config)).deliver
        end
    end
end

