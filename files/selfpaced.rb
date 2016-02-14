#! /usr/bin/ruby
# Script for selecting self paced course
require 'json'

case ARGV[0]
when "hiera"
  command = "hiera.sh"
else
  command = "bash"
end

container = %x{docker run --add-host=puppet:172.17.0.1 --expose=80 -Pi agent sh -c "sleep 300}.chomp
container_info = JSON.parse(%x{docker inspect #{container}})

puts container_info[0]["NetworkSettings"]['Ports']['80/tcp'][0]['HostPort']

exec( "docker exec -it #{container} bash; cleanup" )
