require 'spec_helper'
require 'fileutils'
require 'working_dir'

include FileUtils
describe WorkingDir do
    before do
        rm_f '/tmp/yarb' if File.exists?('/tmp/yarb') 
    end
    after do
        rm_f '/tmp/yarb' if File.exists?('/tmp/yarb') 
    end
    describe 'in' do
        it 'creates itself' do
            WorkingDir.new('/tmp/yarb').in {
                File.should exist('/tmp/yarb')
                File.should be_directory('/tmp/yarb')
            }
        end
        
        it 'runs block in there' do
            was_run_in = ''
            WorkingDir.new('/tmp/yarb').in {
                was_run_in = `pwd`.strip
            }
            was_run_in.should == '/tmp/yarb'
        end
        
        it 'cleans up mess' do
            WorkingDir.new('/tmp/yarb').in {
                system 'touch blah.txt'
            }
            File.exists?('/tmp/yarb').should be_false
        end

        it 'complains if there is no access' do
            lambda {
                WorkingDir.new('/root/yarb').in {}
            }.should raise_exception(EnvironmentException)
        end
        it 'complains if it is no temp fir' do
            lambda {
                WorkingDir.new('yarb').in {}
            }.should raise_exception(EnvironmentException)
        end
    end
end
