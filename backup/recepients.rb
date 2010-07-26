# recepients.rb
# specify which recepients need to be notified of scuccesses and failures

set :smtp_server, 'mail.r-westgeest.speedlinq.nl'
set :from_email_address, 'systeembeheer@westgeest-intern.com'

on :success, :recepient => 'rob@westgeest-consultancy.com', :template => 'backup_success_details.rmail'
on :success, :recepient => 'rob@westgeest-consultancy.com', :template => 'backup_success.rmail'
on :success, :recepient => 'chrisje@westgeest-coaching.com', :template => 'backup_success.rmail'

on :failure, :recepient => 'rob@westgeest-consultancy.com', :template => 'backup_failure_details.rmail'
on :failure, :recepient => 'rob@westgeest-consultancy.com', :template => 'backup_failure.rmail'
on :failure, :recepient => 'chrisje@westgeest-coaching.com', :template => 'backup_failure.rmail'
