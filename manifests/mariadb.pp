#
# [*version*]
#   The minor version (X.Y) to install. Defaults to one of the
#   latest if none is specified (this may be changed without notice).
#
# [*firewall*]
#   Whether or not to configure the firewall for the repo and key server
#
class mysql::mariadb (
  $version        = $::mysql::version,
  $firewall       = $::mysql::bool_firewall,
  $apt_mirror_url = 'http://mirrors.supportex.net',
  $apt_key        = '1BB943DB',
  $apt_keyserver  = 'keyserver.ubuntu.com',
) {

  case $::operatingsystem {
    /^(Debian|Ubuntu|Mint)$/: {

      if ( ( $version == '' ) or ( $version == undef ) ) {
        $minor_version = '10.0'
      } else {
        $minor_version = inline_template('<%=@version.to_s.match(/\d+.\d+/)[0] %>')
      }

      $distro_lc     = inline_template("<%= scope.lookupvar('::operatingsystem').downcase %>")
      $distro_url    = "${apt_mirror_url}/mariadb/repo/${minor_version}/${distro_lc}"

      apt::repository { 'mariadb':
        url        => $distro_url,
        distro     => $::lsbdistcodename,
        repository => 'main',
        key        => $apt_key,
        keyserver  => $apt_keyserver,
        before     => Package['mysql']
      }

      if any2bool($firewall) {
        firewall { 'mysql-repo-mariadb':
          destination    => [ 'keyserver.ubuntu.com', 'mirrors.supportex.net' ],
          destination_v6 => [ 'keyserver.ubuntu.com', 'mirrors.supportex.net' ],
          protocol       => 'tcp',
          port           => 80,
          direction      => 'output',
        }

        Service['iptables'] -> Apt::Key[$apt_key]
        Service['iptables'] -> Apt::Repository['mariadb']
      }

    }

    default: {
      fail('mysql::mariadb currently only supports debian-based systems')
    }

  }
}
