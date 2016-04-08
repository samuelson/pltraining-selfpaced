class selfpaced::webpage (
  $docroot = $selpaced::params::docroot
) inherits selfpaced::params {

  file {'/var/www/index.html':
    ensure => file,
    source => 'puppet:///modules/selfpaced/index.html',
  }
  file {'/var/www/docs.html':
    ensure => file,
    source => 'puppet:///modules/selfpaced/docs.html',
  }

}
