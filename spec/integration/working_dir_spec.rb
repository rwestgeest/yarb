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
            }
            File.should exist('/tmp/yarb')
            File.should be_directory('/tmp/yarb')
        end
        it 'creates itself' do
            was_run = false
            WorkingDir.new('/tmp/yarb').in {
                was_run = true                
            }
            was_run.should be_true
        end
        it 'complains if there is no access' do
            lambda {
                WorkingDir.new('/root/yarb').in {}
            }.should raise_exception(EnvironmentException)
        end
    end
end
