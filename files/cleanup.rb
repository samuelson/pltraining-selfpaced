#! /usr/bin/ruby
# This script runs after the container to clean up the puppet environment
require 'json'
require 'puppetclassify'
require 'date'
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

AUTH_INFO = OPTIONS['AUTH_INFO'] || {
  "ca_certificate_path" => "#{CONFDIR}/ssl/ca/ca_crt.pem",
  "certificate_path"    => "#{CONFDIR}/ssl/certs/#{MASTER_HOSTNAME}.pem",
  "private_key_path"    => "#{CONFDIR}/ssl/private_keys/#{MASTER_HOSTNAME}.pem"
}

CLASSIFIER_URL = OPTIONS['CLASSIFIER_URL'] || "http://#{MASTER_HOSTNAME}:4433/classifier-api"

TIMEOUT = OPTIONS['TIMEOUT'] || "1000"

def remove_node_group(username)
  puppetclassify = PuppetClassify.new(CLASSIFIER_URL, AUTH_INFO)
  certname = "#{username}.#{USERSUFFIX}"

  begin
    group_id = puppetclassify.groups.get_group_id(certname)
    puppetclassify.groups.delete_group(group_id)
  rescue => e
    puts "Error removing node group #{certname}: #{e.message}"
  end

  "Node group #{certname} removed"
end

def remove_certificate(username)
  begin
    %x{puppet cert clean #{username}.#{USERSUFFIX}}
    %x{puppet node purge #{username}.#{USERSUFFIX}}
  rescue => e
    puts "Error cleaning certificate #{username}.#{USERSUFFIX}: #{e.message}"
  end

  "Certificate #{username}.#{USERSUFFIX} removed"
end

def remove_environment(username)
  begin
    environment_path = "#{ENVIRONMENTS}/#{username}".gsub("-","_")
    if File.exist?("#{environment_path}") then
      %x{rm -rf #{environment_path}}
    else
      puts "Environment not found"
    end
  rescue => e
    puts "Error removing environment #{username}: #{e.message}"
  end

  "Environment #{username} removed"
end

def remove_container(username)
  begin
    %x{docker rm -f #{username}}
  rescue => e
    puts "Error removing container #{username}: #{e.message}"
  end

  "Container #{username} removed"
end

containers = %x{docker ps -q}

containers.each_line do |container|
  container_info = JSON.parse(%x{docker inspect #{container}})[0]
  hostname = container_info['Config']['Hostname'].split('.')[0]
  starttime = DateTime.parse(container_info['State']['StartedAt'])
  stoptime = starttime + Rational(TIMEOUT.to_i, 86400)

  if DateTime.now > stoptime
    begin
      remove_environment(hostname)
      remove_certificate(hostname)
      remove_node_group(hostname)
      remove_container(container_info['Id'])
    rescue => e
      puts e
    end
  end
end
