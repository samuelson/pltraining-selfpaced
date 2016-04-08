class selfpaced::wetty (
  $wetty_install_dir = $::selfpaced::params::wetty_install_dir
) inherits selfpaced::params {

  file { '/usr/lib/systemd/system/wetty.service':
    ensure => 'present',
    mode   => '0755',
    source => 'puppet:///modules/selfpaced/wetty.conf',
  }

  service { 'wetty':
    ensure    => 'running',
    enable    => true,
    require   => Exec['npm install -g'],
    subscribe => File['/usr/lib/systemd/system/wetty.service'],
  }

  vcsrepo { $wetty_install_dir:
    source   => 'https://github.com/puppetlabs/wetty.git',
    provider => 'git',
  }

  exec { 'npm install -g':
    path    => '/usr/local/bin:/usr/bin:/bin',
    cwd     => $wetty_install_dir,
    unless  => 'npm -g list wetty',
    require => [Class['nodejs'],Vcsrepo[$wetty_install_dir]],
  }

}
