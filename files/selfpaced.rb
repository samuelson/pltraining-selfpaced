#! /usr/bin/ruby
# Script for selecting self paced course
require 'json'
require 'puppetclassify'
require 'fileutils'

OPTIONS = YAML.load_file('/etc/selfpaced.yaml') rescue {}

PUPPET    =  OPTIONS['PUPPET'] || '/opt/puppetlabs/bin/puppet'

LOGFILE   =  OPTIONS['LOGFILE'] || '/var/log/selfpaced'
CERT_PATH =  OPTIONS['CERT_PATH'] || 'certs'

IMAGE_NAME =  OPTIONS['IMAGE_NAME'] || 'agent'

CONFDIR      =  OPTIONS['CONFDIR'] || '/etc/puppetlabs/puppet'
CODEDIR      =  OPTIONS['CODEDIR'] || '/etc/puppetlabs/code'
ENVIRONMENTS = "#{CODEDIR}/environments"

USERSUFFIX   =  OPTIONS['USERSUFFIX'] || 'try.puppet.com'
PUPPETCODE   =  OPTIONS['PUPPETCODE'] || '/root/puppetcode'

MASTER_HOSTNAME = OPTIONS['PUPPETMASTER'] || `hostname -f`.strip

DOCKER_GROUP    = OPTIONS['DOCKER_GROUP'] || 'docker'
DOCKER_IP       = OPTIONS['DOCKER_IP'] || `facter ipaddress_docker0`.strip

AUTH_INFO = OPTIONS['AUTH_INFO'] || {
    "ca_certificate_path" => "#{CONFDIR}/ssl/ca/ca_crt.pem",
    "certificate_path"    => "#{CONFDIR}/ssl/certs/#{MASTER_HOSTNAME}.pem",
    "private_key_path"    => "#{CONFDIR}/ssl/private_keys/#{MASTER_HOSTNAME}.pem"
}

CLASSIFIER_URL = OPTIONS['CLASSIFIER_URL'] || "http://#{MASTER_HOSTNAME}:4433/classifier-api"

TIMEOUT = OPTIONS['TIMEOUT'] || "300"

def classify(environment, hostname, groups=[''])
  puppetclassify = PuppetClassify.new(CLASSIFIER_URL, AUTH_INFO)
  certname = "#{hostname}.#{USERSUFFIX}"
  groupstr = groups.join('\,')

  group_hash = {
    'name'               => certname,
    'environment'        => environment,
    'environment_trumps' => true,
    'parent'             => '00000000-0000-4000-8000-000000000000',
    'classes'            => {}
  }
  group_hash['rule'] = ['or', ['=', 'name', certname]]

  begin
    puppetclassify.groups.create_group(group_hash)
  rescue => e
    raise "Could not create node group #{certname}: #{e.message}"
  end

  "Created node group #{certname} assigned to environment #{environment}"
end

words = File.readlines("/usr/local/share/words/places.txt").each { |l| l.chomp! }
container_name = words[rand(words.length - 1)] + "-" + words[rand(words.length - 1)]
environment_name = container_name.gsub('-','_')

case ARGV[0]
when "autoloading","classes","cli_intro","code","facter_intro","hiera","hiera_intro","infrastructure","inheritance","module","parser","puppet_lint","relationships","resources","smoke_test","testing","troubleshooting","unit_test","validating","get_hiera1","get_hiera2","get_hiera3","get_hiera4","get_hiera5"
  course = ARGV[0]
else
  course = "default"
end

# Create environment
FileUtils.mkdir_p "#{ENVIRONMENTS}/#{environment_name}/modules"
FileUtils.mkdir_p "#{ENVIRONMENTS}/#{environment_name}/manifests"

# Create site.pp with include course_selector::course::${course}
File.open("#{ENVIRONMENTS}/#{environment_name}/manifests/site.pp", 'w') { |file|
  file.write "node default {\n"
  file.write "  include course_selector::course::#{course}\n"
  file.write "}\n"
}

# Print a little explaination of what's happening
puts "Setting up self paced eLearning environment"
puts "-------------------------------------------"


# Create node group
classify(environment_name, container_name)


# Run container
container = %x{docker run --volume #{ENVIRONMENTS}/#{environment_name}:#{PUPPETCODE} --volume /sys/fs/cgroup:/sys/fs/cgroup:ro --hostname #{container_name}.#{USERSUFFIX} --name #{container_name} --add-host=puppet:#{DOCKER_IP} --expose=80 -Ptd #{IMAGE_NAME} sh -c "/usr/lib/systemd/systemd"}.chomp

# Set up shutdown timeout
pid = Process.fork do 
  sleep TIMEOUT.to_i
  exec("docker exec -dt #{container} sh -c 'shutdown now'")
end
Process.detach(pid)

puts <<-WELCOME
------------------------------------------------------------

       Welcome to the Puppetlabs eLearning environment
           Your session will expire in 5 minutes

              Type `puppet agent -t` to begin

------------------------------------------------------------
WELCOME

# Hand off user to container terminal
exec( "docker exec -it #{container} script -qc \"bash\" /dev/null; cleanup #{container_name}" )
