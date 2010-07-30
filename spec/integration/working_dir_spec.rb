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
    it 'can create itself' do
        WorkingDir.new('/tmp/yarb').create
        File.should exist('/tmp/yarb')
        File.should be_directory('/tmp/yarb')
    end
    it 'complains if there is no access' do
        lambda {
            WorkingDir.new('/root/yarb').create
        }.should raise_exception(EnvironmentException)
    end

end
