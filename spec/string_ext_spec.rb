require 'string_ext'

describe String do
    describe "start_with" do
        it "returns true if the string starts wth the given string" do
            "asd_dsa".start_with?('as').should be_true
            "asd_dsa".start_with?('ds').should be_false
        end    
    end
    describe "end_with" do
        it "returns true if the string ends wth the given string" do
            "asd_dsa".end_with?('sa').should be_true
            "asd_dsa".end_with?('a').should be_true
            "asd_dsa".end_with?('dsa').should be_true
            "asd_dsa".end_with?('ds').should be_false
        end    
    end
end

