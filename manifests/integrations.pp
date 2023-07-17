# == Class: newrelic_infra::integrations
#
class newrelic_infra::integrations (
  $integrations = {}
) {
  require ::newrelic_infra::agent

  # Setup agent package repo
  case $::operatingsystem {
    'Debian', 'Ubuntu', 'RedHat', 'CentOS','Amazon', 'OracleLinux', 'Raspbian': {
      ensure_packages($integrations)
    }
    'OpenSuSE', 'SuSE', 'SLED', 'SLES': {
      keys($integrations).each | Integer $i, String $integration_name | {
        if $integrations[$integration_name]['ensure'] in ['present', 'latest'] {
          exec { "install_${integration_name}":
            command => "/usr/bin/zypper install -y ${integration_name}",
            path    => ['/usr/local/sbin', '/usr/local/bin', '/sbin', '/bin', '/usr/bin'],
            require => Exec['add_newrelic_integrations_repo'],
            unless  => "/bin/rpm -qa | /usr/bin/grep ${integration_name}"
          }
        }
        elsif $integrations[$integration_name]['ensure'] == 'absent' {
          exec { "install_${integration_name}":
            command => "/usr/bin/zypper remove -y ${integration_name}",
            path    => ['/usr/local/sbin', '/usr/local/bin', '/sbin', '/bin', '/usr/bin'],
            onlyif  => "/bin/rpm -qa | /usr/bin/grep ${integration_name}"
          }
        }
      }
    }
    default: {
      fail('New Relic Integrations package is not yet supported on this platform')
    }
  }
}
