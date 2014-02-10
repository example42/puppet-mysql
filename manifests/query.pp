# Define mysql::query
#
define mysql::query (
  $mysql_query,
  $mysql_db             = undef,
  $mysql_user           = '',
  $mysql_password       = '',
  $mysql_host           = '',
  $mysql_query_filepath = '/root/puppet-mysql'
  ) {

  if ! defined(File[$mysql_query_filepath]) {
    file { $mysql_query_filepath:
      ensure => directory,
    }
  }

  file { "mysqlquery-${name}.sql":
    ensure  => present,
    mode    => '0600',
    owner   => $mysql::config_file_owner,
    group   => $mysql::config_file_group,
    path    => "${mysql_query_filepath}/mysqlquery-${name}.sql",
    content => template('mysql/query.erb'),
    notify  => Exec["mysqlquery-${name}"],
    require => Service['mysql'],
  }


  $arg_mysql_user = $mysql_user ? {
    ''      => '',
    default => "-u ${mysql_user}",
  }

  $arg_mysql_host = $mysql_host ? {
  ''      => '',
  default => "-h ${mysql_host}",
  }

  $arg_mysql_password = $mysql_password ? {
    ''      => '',
    default => "--password=\"${mysql_password}\"",
  }

  $arg_mysql_defaults_file = $mysql::real_root_password ? {
    ''      => '',
    default => '--defaults-file=/root/.my.cnf',
  }

  $exec_require = $mysql::real_root_password ? {
    ''      => [ Service['mysql'], File["mysqlquery-${name}.sql"] ],
    default => [ Service['mysql'], File["mysqlquery-${name}.sql"] , Class['mysql::password'] ],
  }

  exec { "mysqlquery-${name}":
    command     => "mysql ${arg_mysql_defaults_file} \
                    ${arg_mysql_user} ${arg_mysql_password} ${arg_mysql_host} \
                    < ${mysql_query_filepath}/mysqlquery-${name}.sql",
    require     => $exec_require,
    refreshonly => true,
    subscribe   => File["mysqlquery-${name}.sql"],
    path        => [ '/usr/bin' , '/usr/sbin' ],
  }

}
