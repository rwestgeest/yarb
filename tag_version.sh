#!/usr/bin/env ruby
require 'yarb_version'
def error(message)
  puts message
  exit 1
end

tag = ARGV[0]

error("no tag supplied") if tag.nil? 
tag = Yarb::VERSION + '_' + tag

answer='-'
while not ["yes", "no"].include?(answer) do
	print "tagging #{tag} ok [yes/no]"
	answer = $stdin.gets.strip
end

exit(1) if answer == 'no'

system  "svn cp -m 'created tag #{tag}' svn+ssh://svn.westgeest-consultancy.com/home/svn/yarb/trunk svn+ssh://svn.westgeest-consultancy.com/home/svn/yarb/tags/#{tag}" 
  
