class selfpaced::docker inherits selfpaced::params {

  include docker
  docker::image {'maci0/systemd':}
  docker::image { 'agent':
    docker_dir => '/tmp/agent',
    subscribe => File['/tmp/agent'],
    require => Docker::Image['maci0/systemd'],
  }
  file { '/tmp/agent':
    ensure => directory,
    recurse => true,
    source => 'puppet:///modules/selfpaced/agent',
  }
}
