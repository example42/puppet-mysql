# Define mysql::queryfile
#
define mysql::user (
  $mysql_user,
  $mysql_password       = '',
  $mysql_password_hash  = '',
  $mysql_host           = 'localhost',
  $mysql_grant_filepath = '/root/puppet-mysql'
  ) {

  include mysql

  if (!defined(File[$mysql_grant_filepath])) {
    file {$mysql_grant_filepath:
      ensure => directory,
      path   => $mysql_grant_filepath,
      owner  => $mysql::config_file_owner,
      group  => $mysql::config_file_group,
      mode   => '0700',
    }
  }

  $nice_mysql_host = regsubst($mysql_host, '/', '_')
  $mysql_grant_file = "mysqluser-${mysql_user}-${nice_mysql_host}.sql"

  file { $mysql_grant_file:
      ensure  => present,
      mode    => '0600',
      owner   => $mysql::config_file_owner,
      group   => $mysql::config_file_group,
      path    => "${mysql_grant_filepath}/${mysql_grant_file}",
      content => template('mysql/user.erb'),
  }

  exec { "mysqluser-${mysql_user}-${nice_mysql_host}":
      command     => "mysql --defaults-file=/root/.my.cnf -uroot < ${mysql_grant_filepath}/${mysql_grant_file}",
      require     => [ Service['mysql'], File['/root/.my.cnf'] ],
      subscribe   => File[$mysql_grant_file],
      path        => [ '/usr/bin' , '/usr/sbin' ],
      refreshonly => true,
  }

}
