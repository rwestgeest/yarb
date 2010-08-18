require 'runt'

module Runt
    alias_method :super_method_missing, :method_missing 
    
    def method_missing(method, *args) 
        if method.to_s.include?('_in_')
            day_in_month, month = method.to_s.split('_in_')
            month = REYear.new(month_number(month))
            return month  & self.send(day_in_month)
        end
        return super_method_missing(method, *args) 
    end
    
    private 
    def month_number(month)
        month = month.to_sym
        months = [:january, :february, :march, :april, :may, :june, :july, :august, :september, :october, :november, :december] 
        months.include?(month) && months.index(month) + 1 || raise("#{month} is not a valid month")
    end
end
