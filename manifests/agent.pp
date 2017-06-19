# == Class: newrelic_infra::agent
#
# === Required Parameters
# [*ensure*]
#   Infrastructure agent version ('absent' will uninstall)
#
# [*license_key*]
#   New Relic license key
#
# [*package_repo_ensure*]
#   Optional flag to disable setting up New Relic's package repo.
#   This is useful in the event the newrelic-infra package has been
#   mirrored to a repo that already exists on the system
#
# [*proxy*]
#   Optional value for directing the agent to use a proxy in http(s)://domain.or.ip:port format
#
# [*display_name*]
#   Optional. Override the auto-generated hostname for reporting.
#
# [*verbose*]
#   Optional. Enables verbose logging for the agent when set the value with 1, the default value is 0.
#
# [*log_file*]
#   Optional. To log to another location, provide a full path and file name. When not set, the agent logs to the system log files.
#   Typical default locations:
#   - Amazon Linux, CentOS, RHEL: `/var/log/messages`
#   - Debian, Ubuntu: `/var/log/syslog`
#   - Windows Server: `C:\Program Files\New Relic\newrelic-infra\newrelic-infra.log`
#
# [*custom_attributes*]
#   Optional hash of attributes to assign to this host (see docs https://docs.newrelic.com/docs/infrastructure/new-relic-infrastructure/configuration/configure-infrastructure-agent#attributes)
#
# === Authors
#
# New Relic, Inc.
#
class newrelic_infra::agent (
  $ensure       = 'latest',
  $license_key  = '',
  $package_repo_ensure  = 'present',
  $proxy = '',
  $display_name = '',
  $verbose = '',
  $log_file = '',
  $custom_attributes = {},
) {
  # Validate license key
  if $license_key == '' {
    fail("New Relic license key not provided")
  }


  # Setup agent package repo
  case $::operatingsystem {
    'Debian', 'Ubuntu': {
      package { 'apt-transport-https':
        ensure => 'installed',
      }
      apt::source { 'newrelic_infra-agent':
        ensure       => $package_repo_ensure,
        location     => "https://download.newrelic.com/infrastructure_agent/linux/apt",
        release      => $lsbdistcodename,
        repos        => "main",
        architecture => "amd64",
        key          => {
            'id'        => "A758B3FBCD43BE8D123A3476BB29EE038ECCE87C",
            'source'    => "https://download.newrelic.com/infrastructure_agent/gpg/newrelic-infra.gpg",
        },
        require      => Package['apt-transport-https'],
        notify       => Exec['apt_update'],
      }
      # work around necessary to get Puppet and Apt to get along on first run, per ticket open as of this writing
      # https://tickets.puppetlabs.com/browse/MODULES-2190?focusedCommentId=341801&page=com.atlassian.jira.plugin.system.issuetabpanels:comment-tabpanel#comment-341801
      exec { 'newrelic_infra_apt_get_update':
        command     => 'apt-get update',
        cwd         => '/tmp',
        path        => ['/usr/bin'],
        require     => Apt::Source['newrelic_infra-agent'],
        subscribe   => Apt::Source['newrelic_infra-agent'],
        refreshonly => true,
      }
      package { 'newrelic-infra':
        ensure  => $ensure,
        require => Exec['newrelic_infra_apt_get_update'],
      }
    }
    'RedHat', 'CentOS','Amazon': {
      if ($::operatingsystem == 'Amazon') {
        $repo_releasever = "6"
      } else {
        $repo_releasever = $operatingsystemmajrelease
      }
      yumrepo { 'newrelic_infra-agent':
        ensure        => $package_repo_ensure,
        descr         => "New Relic Infrastructure",
        baseurl       => "https://download.newrelic.com/infrastructure_agent/linux/yum/el/$repo_releasever/x86_64",
        gpgkey        => "https://download.newrelic.com/infrastructure_agent/gpg/newrelic-infra.gpg",
        gpgcheck      => true,
        repo_gpgcheck => true,
      }
      package { 'newrelic-infra':
        ensure  => $ensure,
        require => Yumrepo['newrelic_infra-agent'],
      }
    }
    default: {
      fail('New Relic Infrastructure agent is not yet supported on this platform')
    }
  }


  # Setup agent config
  file { '/etc/newrelic-infra.yml':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template('newrelic_infra/newrelic-infra.yml.erb'),
    notify  => Service['newrelic-infra'] # Restarts the agent service on config changes
  }

  # we use Upstart on CentOS 6 systems and derivatives, which is not the default
  if (($::operatingsystem == 'CentOS' or $::operatingsystem == 'RedHat')and $::operatingsystemmajrelease == '6')
  or ($::operatingsystem == 'Amazon') {
    service { 'newrelic-infra':
      ensure => 'running',
      provider => 'upstart',
      require => Package['newrelic-infra'],
    }
  } else {
    # Setup agent service
    service { 'newrelic-infra':
      ensure => 'running',
      require => Package['newrelic-infra'],
    }
  }
}
