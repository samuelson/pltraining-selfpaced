class selfpaced::lxd {

  include apt
  apt::ppa { 'ppa:ubuntu-lxc/lxc-stable': }

  package { ['lxd','ruby-dev','g++']:
    ensure  => present,
    require => Apt::Ppa['ppa:ubuntu-lxc/lxc-stable'],
  }

  file { '/var/lib/lxd/files':
    ensure => directory,
  }
}
