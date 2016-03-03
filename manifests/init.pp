class selfpaced (
  $wetty_install_dir = '/root/wetty'
) {
  include nodejs
  include docker
  docker::image {'phusion/baseimage':}
  docker::image { 'agent':
    docker_dir => '/tmp/agent',
    subscribe => File['/tmp/agent'],
    require => Docker::Image['phusion/baseimage'],
  }
  file { '/tmp/agent':
    ensure => directory,
    recurse => true,
    source => 'puppet:///modules/selfpaced/agent',
  }

  # Script to trigger filesync - Should be replaced ASAP
  file {'/usr/local/bin/filesync':
    mode => '0755',
    source => 'puppet:///modules/selfpaced/filesync',
  }    

  file {'/usr/local/bin/selfpaced':
    mode => '0755',
    source => 'puppet:///modules/selfpaced/selfpaced.rb',
  }    
  file {'/usr/local/share/words':
    ensure => directory
  }
  file {'/usr/local/share/words/places.txt':
    source => 'puppet:///modules/selfpaced/places.txt',
  } 
  file {'/usr/local/bin/cleanup':
    mode => '0755',
    source => 'puppet:///modules/selfpaced/cleanup.rb',
  }

  include nginx
  nginx::resource::vhost { 'selfpaced.puppetlabs.com':
    proxy => 'http://127.0.0.1:3000'
  }
  package { 'puppetclassify':
    ensure   => present,
    provider => 'gem',
  }

  vcsrepo { '/etc/puppetlabs/code-staging/modules/course_selector':
    ensure   => present,
    provider => 'git',
    source   => 'https://github.com/puppetlabs/pltraining-course_selector'
  }

  include selfpaced::wetty
}
