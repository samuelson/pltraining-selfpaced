class selfpaced (
  $wetty_install_dir = '/root/wetty'
) {
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
  nginx::resource::vhost { 'try.puppet.com':
    ssl_port               => '443',
    ssl                    => true,
    ssl_cert               => '/etc/ssl/try.puppet.com.crt',
    ssl_key                => '/etc/ssl/try.puppet.com.key',
    use_default_location   => false,
    locations              => {
      '/sandbox/'          => {
        proxy_read_timeout => '1h',
        proxy_connect_timeout => '1h',
        proxy              => 'http://127.0.0.1:3000',
        proxy_set_header => [
          'Upgrade $http_upgrade',
          'Connection "Upgrade"',
        ],
        rewrite_rules     => [
          '/sandbox(.*) /$1  break'
        ]
      },
      '/' => {
        www_root => '/var/www'
      }
    }
  }
  package { 'puppetclassify':
    ensure   => present,
    provider => 'gem',
  }

  vcsrepo { '/etc/puppetlabs/code/modules/course_selector':
    ensure   => latest,
    provider => 'git',
    source   => 'https://github.com/puppetlabs/pltraining-course_selector'
  }

  class { 'abalone':
    port    => '3000',
    command => 'selfpaced',
    method  => 'command',
    params  => ['course'],
  }
  include selfpaced::webpage

  firewall { '000 accept outbound 80, 443, and 8140 traffic on docker0':
    iniface     => 'docker0',
    chain       => 'FORWARD',
    proto       => 'tcp',
    dport       => ['! 80','! 443','! 8140'],
    action      => 'reject',
  }
}
