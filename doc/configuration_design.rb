backup do
    archive 'some_name' do
        files 'dir1', 'dir2', 'dir3'
        file 'file'
        
        postgres_database 'some_db' do
            sudo 'postgres'
        end
         
        destination '/some_path'
    end
    
    on_error do 
        send_mail :error_mail 
    end
    
    on_success do 
        send_mail :success_mail 
    end

    delivery do
        son do
            keep 31
        end
        
        father do
            on_each last_friday
            keep 12
        end
        
        grandfather do
            on_each REYear.new(1) & first_sunday
            keep 5
        end
    end
end

mail do 
    error_mail do 
        to 'rob@blah.com'
        from 'root@blah.com'
        
        by_smtp 'mail.r-westgeest.speedlinq.nl'
        
        by_sendmail 'localhost'
        subject 'error in backup'
        body_text 'backup was niet gelukt\nhieronder vind je de log'
        include_log
    end    
    
    success_mail do 
        to 'rob@blah.com'
        from 'root@blah.com'
        
        by_smtp 'mail.r-westgeest.speedlinq.nl'
        
        by_sendmail 'localhost'
        
        subject 'succesful backup'
        body_text 'backup was succesful'
    end    
end
