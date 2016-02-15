#! /usr/bin/ruby
# Script for selecting self paced course
require 'json'

case ARGV[0]
when "autoloading","classes","cli_intro","code","facter_intro","hiera","hiera_intro","infrastructure","inheritance","module","parser","puppet_lint","relationships","resources","smoke_test","testing","troubleshooting","unit_test","validating"
  course = "puppet apply -e 'include course_selector::course::#{ARGV[0]}' --modulepath=/tmp; bash"
else
  course = "puppet apply -e 'include course_selector::course::default' --modulepath=/tmp; bash"
end

container = %x{docker run --add-host=puppet:172.17.0.1 --expose=80 -Ptd agent sh -c "sleep 300"}.chomp
container_info = JSON.parse(%x{docker inspect #{container}})

puts container_info[0]["NetworkSettings"]['Ports']['80/tcp'][0]['HostPort']

exec( "docker exec -it #{container} sh -c \"#{course}\"; cleanup" )
