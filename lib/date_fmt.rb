require 'date'

module DateFmt 
    def today_as_string
        Date.today.as_string
    end
end
class Date
  def as_string
    strftime('%Y-%m-%d')
  end
end
