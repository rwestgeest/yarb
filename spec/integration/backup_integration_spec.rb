require 'spec_helper'
require 'fileutils'
require 'backup_configuration'
include FileUtils

describe 'backups' do
    
    def tar_list
        expected_tar = output_file "destination/simple_tar_son_#{Date.today.strftime('%Y-%m-%d')}.tgz"
        return 'output tar not present' unless File.exists?(expected_tar)
        `tar tvzf #{expected_tar}`
    end
        
    def run_backup recipe_file
#        recipe = BackupConfiguration.from_file(File.join(File.dirname(__FILE__),recipe_file))  
#        backup = recipe.backup
#        backup.run
        system "#{File.join(PROJECT_ROOT, 'bin', 'yarb')} --recipe #{File.join(File.dirname(__FILE__),recipe_file)}"
    end    
    
    before do
        clean_input
        clean_output
        create_input_file 'mydir/file1' 
        create_input_file 'mydir/file2' 
    end
    
    after do
        clean_input
        clean_output
    end
    
    it "can make a simple directory backup" do
    #    pending 'waiting for backup runner to run'
        result = run_backup 'simple_directory_archive.recipe'
        result.should be_true, 'backup should be succesful'
        tar_list.should include 'mydir/file1' 
        tar_list.should include 'mydir/file2' 
    end
end
