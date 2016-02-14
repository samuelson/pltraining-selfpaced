class selfpaced {
  include docker
  docker::image {'phusion/baseimage':}
  docker::image { 'agent':
    docker_file => '/tmp/agent/Dockerfile',
    subscribe => File['/tmp/agent'],
    require => Docker::Image['phusion/baseimage'],
  }
  file { '/tmp/agent':
    ensure => directory,
    recurse => true,
    source => 'puppet:///modules/selfpaced/agent/',
  }

  file {'/usr/local/selfpaced':
    mode => '0755',
    source => 'puppet:///modules/selfpaced/selfpaced.rb',
  }    
  file {'/usr/local/cleanup':
    mode => '0755',
    source => 'puppet:///modules/selfpaced/cleanup.rb',
  }
}
