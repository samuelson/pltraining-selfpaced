class selfpaced::lxd {

  include apt
  apt::ppa { 'ppa:ubuntu-lxc/lxc-stable': }

  package { ['lxd','ruby-dev','g++','make','git']:
    ensure  => present,
    require => Apt::Ppa['ppa:ubuntu-lxc/lxc-stable'],
  }

  file { '/var/lib/lxd/files':
    ensure => directory,
  }
}
