#! /usr/bin/ruby
# This script runs after the container to clean up the puppet environment
require 'json'
require 'puppetclassify'
OPTIONS = YAML.load_file('/etc/selfpaced.yaml') rescue {}
PUPPET    =  OPTIONS['PUPPET'] || '/opt/puppetlabs/bin/puppet'

LOGFILE   =  OPTIONS['LOGFILE'] || '/var/log/selfpaced'
CERT_PATH =  OPTIONS['CERT_PATH'] || 'certs'

IMAGE_NAME =  OPTIONS['IMAGE_NAME'] || 'agent'

CONFDIR      =  OPTIONS['CONFDIR'] || '/etc/puppetlabs/puppet'
CODEDIR      =  OPTIONS['CODEDIR'] || '/etc/puppetlabs/code'
ENVIRONMENTS = "#{CODEDIR}/environments"

USERSUFFIX   =  OPTIONS['USERSUFFIX'] || 'selfpaced.puppetlabs.com'
PUPPETCODE   =  OPTIONS['PUPPETCODE'] || '/root/puppetcode'

MASTER_HOSTNAME = OPTIONS['PUPPETMASTER'] || `hostname`.strip

AUTH_INFO = OPTIONS['AUTH_INFO'] || {
  "ca_certificate_path" => "#{CONFDIR}/ssl/ca/ca_crt.pem",
  "certificate_path"    => "#{CONFDIR}/ssl/certs/#{MASTER_HOSTNAME}.pem",
  "private_key_path"    => "#{CONFDIR}/ssl/private_keys/#{MASTER_HOSTNAME}.pem"
}

CLASSIFIER_URL = OPTIONS['CLASSIFIER_URL'] || "http://#{MASTER_HOSTNAME}:4433/classifier-api"

TIMEOUT = OPTIONS['TIMEOUT'] || "300"

CONTAINER_NAME = ARGV[0]

def remove_node_group(username)
  puppetclassify = PuppetClassify.new(CLASSIFIER_URL, AUTH_INFO)
  certname = "#{username}.#{USERSUFFIX}"

  begin
    group_id = puppetclassify.groups.get_group_id(certname)
    puppetclassify.groups.delete_group(group_id)
  rescue => e
    raise "Error removing node group #{certname}: #{e.message}"
  end

  "Node group #{certname} removed"
end

def remove_certificate(username)
  begin
    %x{puppet cert clean #{username}.#{USERSUFFIX}}
  rescue => e
    raise "Error cleaning certificate #{username}.#{USERSUFFIX}: #{e.message}"
  end

  "Certificate #{username}.#{USERSUFFIX} removed"
end

def remove_environment(username)
  begin
    environment_path = "#{ENVIRONMENTS}/#{username}"
    if File.exist?("#{environment_path}") then
      %x{rm -rf #{environment_path}}
    end
  rescue => e
    raise "Error removing environment #{username}: #{e.message}"
  end

  "Environment #{username} removed"
end

# Notify user of shutdown

puts
puts
puts
puts "----------------------------------------"
puts "Cleaning up #{CONTAINER_NAME}.#{USERSUFFIX}"

# Clean up environment

puts
puts "Cleaning up code directory"
remove_environment(CONTAINER_NAME)

# Remove certificate
puts 
puts "Removing Node Certificate"
remove_certificate(CONTAINER_NAME)

# Delete node group
puts
puts "Removing Node Group"
remove_node_group(CONTAINER_NAME)

# Notify User

puts "Please reload the page to start a new session"
