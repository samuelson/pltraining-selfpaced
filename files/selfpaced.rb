#! /usr/bin/ruby
# Script for selecting self paced course
require 'json'

words = File.readlines("/usr/local/share/words/places.txt").each { |l| l.chomp! }
container_name = words[rand(words.length - 1)] + "_" + words[rand(words.length - 1)]

case ARGV[0]
when "autoloading","classes","cli_intro","code","facter_intro","hiera","hiera_intro","infrastructure","inheritance","module","parser","puppet_lint","relationships","resources","smoke_test","testing","troubleshooting","unit_test","validating"
  course = "puppet apply -e 'include course_selector::course::#{ARGV[0]}' --modulepath=/tmp; bash"
else
  course = "puppet apply -e 'include course_selector::course::default' --modulepath=/tmp; bash"
end

# Create environment
# Create node group
# Pin node to group

# Run container
container = %x{docker run --hostname #{container_name}.selfpaced.puppetlabs.com --name #{container_name} --add-host=puppet:172.17.0.1 --expose=80 -Ptd agent sh -c "sleep 300; echo '\neLearning timeout reached, shutting down.\nReload page to start a new session'"}.chomp

# Print a little explaination of what's happening
puts "Setting up self paced eLearning environment"
puts "-------------------------------------------"

# Hand off user to container terminal
exec( "docker exec -it #{container} script -qc \"#{course}\" /dev/null; cleanup" )
