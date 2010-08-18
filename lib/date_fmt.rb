require 'date'

module DateFmt 
    def today_as_string
        Date.today.strftime('%Y-%m-%d')
    end
end
