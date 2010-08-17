class String
    def start_with?(given)
        return index(given) == 0
    end
    def end_with?(given)
        return rindex(given) == (length - given.length)
    end
end
