class selfpaced::webpage (
  $docroot = $selfpaced::params::docroot
) inherits selfpaced::params {

  file {$docroot:
    ensure => directory,
  }
  file {"${docroot}/index.html":
    ensure  => file,
    source  => 'puppet:///modules/selfpaced/index.html',
  }
  file {"${docroot}/js":
    ensure  => directory,
    recurse => true,
    source  => 'puppet:///modules/selfpaced/js',
  }
}
