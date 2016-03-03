class selfpaced::wetty (
  $wetty_install_dir = $::selfpaced::params::wetty_install_dir
) inherits selfpaced::params {

  file { '/etc/init.d/wetty':
    ensure => 'present',
    mode   => '0755',
    source => 'puppet:///modules/selfpaced/wetty.conf',
  }

  service { 'wetty':
    ensure    => 'running',
    enable    => true,
    require   => nodejs::npm['npm-install-dir'],
    subscribe => File['/etc/init.d/wetty'],
  }

  vcsrepo { $wetty_install_dir:
    source   => 'https://github.com/samuelson/wetty.git',
    provider => 'git',
    revision => 'minimal',
  }

  nodejs::npm { 'npm-install-dir':
    list      => true, # flag to tell puppet to execute the package.json file
    directory => $wetty_install_dir,
    require   => Vcsrepo[$wetty_install_dir],   
  }

}
