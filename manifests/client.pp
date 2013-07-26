# Class: mysql::client
#
# Manages mysql client installation
#
# Usage:
# include mysql::client
#
class mysql::client (
  $package         = $mysql::params::package_client,
  $version         = 'present'
) {

  include mysql::params

  package { 'mysql-client':
    ensure => $version,
    name   => $package,
  }

}

