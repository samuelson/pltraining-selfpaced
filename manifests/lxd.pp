class selfpaced::lxd {

  include apt
  apt::ppa { 'ppa:ubuntu-lxc/lxc-stable': }

  package { ['lxd','ruby-dev']:
    ensure  => present,
    require => Apt::Ppa['ppa:ubuntu-lxc/lxc-stable'],
  }

  file { '/var/lib/lxd/files':
    ensure => directory,
  }
  file { '/var/lib/lxd/files/bashrc':
    ensure => file,
    source => 'puppet:///modules/selfpaced/agent/bashrc',
  }
}
