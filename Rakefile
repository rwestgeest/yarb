require 'rubygems'
require 'rake/gempackagetask'
require File.join(File.dirname(__FILE__),'yarb_version')

 desc 'Running all specs'
 task :default => :spec
 task :spec do
    test_files = ['spec/**/*_spec.rb', 'spec/*_spec.rb']
    test_files.each do |file_set|
        Dir[file_set].each do |specfile| 
            require specfile
        end
    end
 end
 
 desc 'Measures test coverage'
 task :coverage do
     rm_f "coverage"
     rm_f "coverage.data"
     rcov = "rcov --aggregate coverage.data"
     system("#{rcov} --spec-only --html spec/*_spec.rb")
     system("#{rcov} --spec-only --html spec/**/*_spec.rb")
 end
 
 spec = Gem::Specification.new do |s| 
  s.name = "yarb"
  s.version = Yarb::VERSION
  s.author = "Rob Westgeest"
  s.email = "rob.westgeest@gmail.com"
  s.homepage = "http://notaresource.blogspot.com/yarb"
  s.platform = Gem::Platform::RUBY
  s.summary = "Yet another ruby backupper"
  s.files = FileList["yarb_version.rb", "Rakefile", "doc/example.recipe", "{bin}/*","{lib}/**/*"].to_a
  s.test_files = FileList["{spec}/**/*_spec.rb"].to_a
  s.has_rdoc = true
  s.require_path = 'yarb'
  s.executables << 'yarb'
  s.add_dependency("rspec", ">= 1.3.0")
end
 
Rake::GemPackageTask.new(spec) do |pkg| 
  rm_f "pkg"
  pkg.need_tar = true 
end 

 
