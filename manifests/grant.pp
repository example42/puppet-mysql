# Define mysql::grant
#
# This define adds a grant to the MySQL server. It creates a file with the
# grant statement and then applies it.
#
# Supported arguments:
# $mysql_db             - The database to apply the grant to.
#                         If not set, defaults to == $title
#                         It supports SQL wildcards (%), ie: 'somedatab%'.
#                         The special value '*' means 'ALL DATABASES'
# $mysql_user           - User to grant the permissions to.
# $mysql_password       - Plaintext password for the user.
# $mysql_create_db      - If you want a $mysql_db database created or not.
#                         Default: true.
# $mysql_privileges     - Privileges to grant to the user.
#                         Defaults to 'ALL'
# $mysql_host           - Host where the user can connect from. Accepts SQL wildcards.
#                         Default: 'localhost'
# $mysql_grant_filepath - Path where the grant files will be stored.
#                         Default: '/root/puppet-mysql'
define mysql::grant (
  $mysql_user,
  $mysql_password,
  $mysql_db                 = '',
  $mysql_db_create_options  = '',
  $mysql_create_db          = true,
  $mysql_privileges         = 'ALL',
  $mysql_host               = 'localhost',
  $mysql_grant_filepath     = '/root/puppet-mysql'
  ) {

  require mysql

  $dbname = $mysql_db ? {
    ''      => $name,
    default => $mysql_db,
  }
  $real_db_create_options = $mysql_db_create_options ? {
    ''      => '',
    default => " ${mysql_db_create_options}",
  }

  # Check for wildcards
  $real_db = $dbname ? {
    /^(\*|%)$/ => '*',
    default    => "`${dbname}`",
  }

  $mysql_grant_file = $dbname ? {
    /^(\*|%)$/ => "mysqlgrant-${mysql_user}-${mysql_host}-all.sql",
    default    => "mysqlgrant-${mysql_user}-${mysql_host}-${dbname}.sql",
  }

  # If dbname has a wildcard, we don't want to create anything
  $bool_mysql_create_db = $dbname ? {
    /(\*|%)/ => false,
    default  => any2bool($mysql_create_db)
  }

  if (!defined(File[$mysql_grant_filepath])) {
    file { $mysql_grant_filepath:
      ensure => directory,
      path   => $mysql_grant_filepath,
      owner  => root,
      group  => root,
      mode   => '0700',
    }
  }

  file { $mysql_grant_file:
    ensure   => present,
    mode     => '0600',
    owner    => root,
    group    => root,
    path     => "${mysql_grant_filepath}/${mysql_grant_file}",
    content  => template('mysql/grant.erb'),
  }

  $exec_command = $mysql::real_root_password ? {
    ''      => "mysql -uroot < ${mysql_grant_filepath}/${mysql_grant_file}",
    default => "mysql --defaults-file=/root/.my.cnf -uroot < ${mysql_grant_filepath}/${mysql_grant_file}",
  }

  $exec_require = $mysql::real_root_password ? {
    ''      => Service['mysql'],
    default => [ Service['mysql'], File['/root/.my.cnf'] ],
  }


  exec { "mysqlgrant-${mysql_user}-${mysql_host}-${dbname}":
    command     => $exec_command,
    require     => $exec_require,
    subscribe   => File[$mysql_grant_file],
    path        => [ '/usr/bin' , '/usr/sbin' ],
    refreshonly => true;
  }

}
