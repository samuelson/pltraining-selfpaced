#! /usr/bin/ruby
# Script for selecting self paced course
require 'json'
require 'puppetclassify'
require 'fileutils'
require 'optparse'

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

TIMEOUT = OPTIONS['TIMEOUT'] || "900"

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
def create_environment(hostname, course_name)

  environment = hostname.gsub('-','_')

  # Create environment
  FileUtils.mkdir_p "#{ENVIRONMENTS}/#{environment}/modules"
  FileUtils.mkdir_p "#{ENVIRONMENTS}/#{environment}/manifests"

  # Create site manifest with include course_selector::course::${course_name}
  File.open("#{ENVIRONMENTS}/#{environment}/manifests/site.pp", 'w') { |file|
    file.write "node default {\n"
    file.write "  include course_selector::course::#{course_name}\n"
    file.write "}\n"
  }

  return environment
end

options = {}
OptionParser.new do |opt|
 opt.on('--course COURSENAME') { |o| options[:course_name] = o }
 opt.on('--uuid CONTAINER') { |o| options[:uuid] = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/.match(o) ? o : nil  }
end.parse!

case options[:course_name]
when "autoloading","classes","cli_intro","code","facter_intro","hiera","hiera_intro","infrastructure","inheritance","module","parser","puppet_lint","relationships","resources","smoke_test","testing","troubleshooting","unit_test","validating","get_hiera1","get_hiera2","get_hiera3","get_hiera4","get_hiera5","exec"
  course = options[:course_name]
else
  course = "default"
end

words = File.readlines("/usr/local/share/words/places.txt").each { |l| l.chomp! }
container_hostname = words[rand(words.length - 1)] + "-" + words[rand(words.length - 1)]
uuid = options[:uuid] || container_hostname

if %x{docker ps} =~ / #{uuid}$/
  container_info = JSON.parse(%x{docker inspect #{options[:uuid]}})[0]
  container_hostname = container_info['Config']['Hostname'].split('.')[0]
  container = container_info['Id']
  environment_name = create_environment(container_hostname,course)
else

  environment_name = create_environment(container_hostname, course)

  # Create node group
  classify(environment_name, container_hostname)


  # Run a new container container
  container = %x{docker run --security-opt seccomp=unconfined --stop-signal=SIGRTMIN+3 --tmpfs /tmp --tmpfs /run --volume #{ENVIRONMENTS}/#{environment_name}:#{PUPPETCODE} --volume /sys/fs/cgroup:/sys/fs/cgroup:ro --hostname #{container_hostname}.#{USERSUFFIX} --name #{uuid} --add-host=puppet:#{DOCKER_IP} --expose=80 -Ptd #{IMAGE_NAME} /sbin/init}.chomp

  puts <<-WELCOME
  ------------------------------------------------------------

          Welcome to the Puppet eLearning environment
             Your session will expire in 15 minutes

                Type `puppet agent -t` to begin

  ------------------------------------------------------------
  WELCOME

end



# Hand off user to container terminal
exec( "docker exec -it #{container} script -qc \"bash\" /dev/null" )
