class selfpaced::webpage (
  $docroot = $selpaced::params::docroot
) inherits selfpaced::params {

  file {$docroot:
    ensure => directory,
  }
  file {"${docroot}/index.html":
    ensure  => file,
    source  => 'puppet:///modules/selfpaced/index.html',
    require => File[$docroot], 
  }
  file {"${docroot}/var/www/docs.html":
    ensure => file,
    source => 'puppet:///modules/selfpaced/docs.html',
    require => File[$docroot], 
  }

}
