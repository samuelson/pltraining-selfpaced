class selfpaced::squid  {
  package {'squid':
    ensure => present,
  }
  file {'/etc/squid/squid.conf':
    ensure  => file,
    source  => 'puppet:///modules/selfpaced/squid.conf',
    require => Package['squid'],
    notify  => Service['squid'],
  }
  service {'squid':
    ensure => running,
    enable => true,
  }
  firewall { '001 forward port 80 to proxy':
    iniface => 'docker0',
    table   => 'nat',
    chain   => 'PREROUTING',
    proto   => 'tcp',
    dport   => '80',
    jump    => 'REDIRECT',
    toports => '3128',
  }
}
