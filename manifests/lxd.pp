class selfpaced::lxd {

  include apt
  apt::ppa { 'ppa:ubuntu-lxc/lxc-stable': }

  package { 'lxd':
    ensure  => present,
    require => Apt::Ppa['ppa:ubuntu-lxc/lxc-stable'],
  }
}
