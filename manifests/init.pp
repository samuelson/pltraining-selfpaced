class selfpaced (
  $docroot = $selfpaced::params::docroot,
  $container_server = 'lxd'
) inherits selfpaced::params {

  if $container_server == 'docker' {
    include selfpaced::docker
    $bridge = 'docker0'
  } else {
    include selfpaced::lxd
    $bridge = 'lxdbr0'
  }

  file {'/usr/local/bin/selfpaced':
    mode                 => '0755',
    content              => epp('selfpaced/selfpaced.rb.epp',{
      'container_server' => $container_server,
    }),
  }
  file {'/usr/local/share/words':
    ensure => directory
  }
  file {'/usr/local/share/words/places.txt':
    source => 'puppet:///modules/selfpaced/places.txt',
  }
  file {'/usr/local/bin/cleanup':
    mode => '0755',
    content              => epp('selfpaced/cleanup.rb.epp',{
      'container_server' => $container_server,
    }),
  }

  include nginx
  nginx::resource::vhost { 'try.puppet.com':
    ssl_port               => '443',
    ssl                    => true,
    ssl_cert               => '/etc/ssl/try.puppet.com.crt',
    ssl_key                => '/etc/ssl/try.puppet.com.key',
    use_default_location   => false,
    locations              => {
      '/sandbox/' => {
        proxy_read_timeout    => '1h',
        proxy_connect_timeout => '1h',
        proxy                 => 'http://127.0.0.1:3000',
        proxy_set_header      => [
          'Upgrade $http_upgrade',
          'Connection "Upgrade"',
        ],
        rewrite_rules         => [
          '/sandbox(.*) /$1  break'
        ]
      },
      '/' => {
        www_root => $docroot
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
    source   => 'https://github.com/puppetlabs/pltraining-course_selector',
    force    => true,
  }

  class { 'abalone':
    port    => '3000',
    command => 'selfpaced',
    method  => 'command',
    params  => ['course'],
  }
  include selfpaced::webpage

  firewall { '000 accept outbound 80, 443, and 8140 traffic on docker0':
    iniface     => $bridge,
    chain       => 'FORWARD',
    proto       => 'tcp',
    dport       => ['! 80','! 443','! 8140'],
    action      => 'reject',
  }
}
