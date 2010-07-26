#!/usr/bin/env ruby
require 'yarb_version'
def error(message)
  puts message
  exit 1
end

tag = Yarb::VERSION + '_' + ARGV[0]

error("no tag supplied") if tag.nil? 

answer='-'
while not ["yes", "no"].include?(answer) do
	print "tagging #{tag} ok [yes/no]"
	answer = $stdin.gets.strip
end

exit(1) if answer == 'no'

system  "svn cp -m 'created tag #{tag}' svn+ssh://svn.westgeest-consultancy.com/home/svn/yarb/trunk svn+ssh://svn.westgeest-consultancy.com/home/svn/yarb/tags/#{tag}" 
  
