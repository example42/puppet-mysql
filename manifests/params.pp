# Class: mysql::params
#
# This class defines default parameters used by the main module class mysql
# Operating Systems differences in names and paths are addressed here
#
# == Variables
#
# Refer to mysql class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It may be imported or inherited by other classes
#
class mysql::params {

  ### Module specific parameters
  $root_password = ''
  $root_cnf_template = 'mysql/root.my.cnf.erb'
  $password_salt = ''

  ### Application related parameters

  $package = $::operatingsystem ? {
    /(?i:FreeBSD)/ => 'databases/mysql56-server',
    default        => 'mysql-server',
  }

  $package_client = $::operatingsystem ? {
    /(?i:Debian|Ubuntu|Mint)/ => 'mysql-client',
    default                   => 'mysql',
  }

  $service = $::operatingsystem ? {
    /(?i:Debian|Ubuntu|Mint)/ => 'mysql',
    /(?i:FreeBsd)/            => 'mysql-server',
    default                   => 'mysqld',
  }

  $service_status = $::operatingsystem ? {
    default => true,
  }

  $process = $::operatingsystem ? {
    default => 'mysqld',
  }

  $process_args = $::operatingsystem ? {
    default => '',
  }

  $process_user = $::operatingsystem ? {
    default => 'mysql',
  }

  $config_dir = $::operatingsystem ? {
    /(?i:Debian|Ubuntu|Mint)/ => '/etc/mysql',
    default                   => '/etc/mysql',
  }

  $config_file = $::operatingsystem ? {
    /(?i:Debian|Ubuntu|Mint)/ => '/etc/mysql/my.cnf',
    default                   => '/etc/my.cnf',
  }

  $config_file_mode = $::operatingsystem ? {
    default => '0644',
  }

  $config_file_owner = $::operatingsystem ? {
    default => 'root',
  }

  $config_file_group = $::operatingsystem ? {
    /(?i:Darwin|FreeBsd)/ => 'wheel',
    default               => 'root',
  }

  $config_file_init = $::operatingsystem ? {
    /(?i:Debian|Ubuntu|Mint)/ => '/etc/default/mysql',
    default                   => '/etc/sysconfig/mysqld',
  }

  $pid_file = $::operatingsystem ? {
    default => '/var/run/mysqld/mysqld.pid',
  }

  $data_dir = $::operatingsystem ? {
    default => '/var/lib/mysql',
  }

  $log_dir = $::operatingsystem ? {
    default => '/var/log/',
  }

  $log_file = $::operatingsystem ? {
    default => '/var/log/mysqld.log',
  }

  $port = '3306'
  $protocol = 'tcp'

  # General Settings
  $my_class = ''
  $source = ''
  $source_dir = ''
  $source_dir_purge = false
  $template = ''
  $version = 'present'
  $options = ''
  $service_autorestart = true
  $service_manage = true
  $absent = false
  $disable = false
  $disableboot = false
  $socket = ''

  ### General module variables that can have a site or per module default
  $monitor = false
  $monitor_tool = ''
  $monitor_target = '127.0.0.1'
  $firewall = false
  $firewall_tool = ''
  $firewall_src = '0.0.0.0/0'
  $firewall_dst = $::ipaddress
  $puppi = false
  $puppi_helper = 'standard'
  $debug = false
  $audit_only = false
  $grant_hash = {}
  $user_hash = {}
  $augeas_hash = {}
  $query_hash = {}
  $queryfile_hash = {}

}
