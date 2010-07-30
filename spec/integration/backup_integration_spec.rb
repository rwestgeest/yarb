require 'spec_helper'
require 'fileutils'
require 'backup_configuration'
include FileUtils

describe 'backups' do
    def input_file file
        File.join(File.dirname(__FILE__), 'input_data', file)
    end 
    
    def output_file file
        File.join(File.dirname(__FILE__), 'output_data', file)
    end
    
    def create_input_file file
        mkdir_p File.dirname(input_file(file))
    end
    
    def tar_list
        return 'output tar not present' unless File.exists?(output_file 'simple_tar.tgz')
        `tar tvzf #{output_file 'simple_tar.tgz'}`
    end
        
    def run_backup recipe_file
        recipe = BackupRecipe.from_file(File.join(File.dirname(__FILE__),recipe_file))  
        backup = recipe.backup

        backup.run
#        system "#{File.join(PROJECT_ROOT, 'bin', 'yarb')} --recipe #{File.join(File.dirname(__FILE__),recipe)}"
    end    
    
    before do
        create_input_file 'mydir/file1' 
        create_input_file 'mydir/file1' 
    end
    
    after do
        clean_input
        clean_output
    end
    
    it "can make a simple directory backup" do
        pending 'waiting for unit specs to complete'
        
        result = run_backup 'simple_directory_archive.recipe'
        result.should be_true, 'backup should be succesful'
        tar_list.should be_include 'mydir/file1' 
        tar_list.should be_include 'mydir/file2' 
    end
end
