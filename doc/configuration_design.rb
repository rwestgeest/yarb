backup do
    archive 'some_name' do
        files 'dir1', 'dir2', 'dir3'
        file 'file'
        
        postgres_database 'some_db' do
            user 'some user'
            password 'some_pw'
            host 'localhost'
        end
         
        destination '/some_path'
    end
    
    on_error do 
        send_mail :error_mail 
    end
    
    on_success do 
        send_mail :success_mail 
    end

    son do
        to_father last_friday
        keep 31
    end
    
    father do
        to_grandfather REYear.new(1) & first_sunday
        keep 12
    end
    
    grandfather do
        keep 5
    end
end

mail do 
    to 'rob@blah.com'
    from 'root@blah.com'
    
    by_smtp 'mail.r-westgeest.speedlinq.nl'
    
    by_sendmail 'localhost'
    
    error_mail do 
        subject 'error in backup'
        body_text 'backup was niet gelukt\nhieronder vind je de log'
        include_log
    end    
    
    success_mail do 
        subject 'succesful backup'
        body_text 'backup was succesful'
    end    
end
