# == Class: newrelic_infra::agent
#
# === Required Parameters
# [*ensure*]
#   Infrastructure agent version ('absent' will uninstall)
#
# [*service_ensure*]
#   Infrastructure agent service status (default 'running')
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
# [*custom_configs*]
#   Optional. A hash of agent configuration directives that are not exposed explicitly. Example:
#   {'payload_compression' => 0, 'selinux_enable_semodule' => false}
#
# [*windows_provider*]
#   Options. Allows for the selection of a provider other than 'windows' for the Windows MSI install. Or allows
#   the windows provider to be used if another provider such as Chocolatey has been specified as the default
#   provider in the puppet installation.
#
# === Authors
#
# New Relic, Inc.
#
class newrelic_infra::agent (
  $ensure               = 'latest',
  $service_ensure       = 'running',
  $license_key          = '',
  $package_repo_ensure  = 'present',
  $proxy                = '',
  $display_name         = '',
  $verbose              = '',
  $log_file             = '',
  $custom_attributes    = {},
  $custom_configs       = {},
  $windows_provider     = 'windows',
) {
  # Validate license key
  if $license_key == '' {
    fail('New Relic license key not provided')
  }

  # Setup agent package repo
  case $::operatingsystem {
    'Debian', 'Ubuntu': {
      ensure_packages('apt-transport-https')
      apt::source { 'newrelic_infra-agent':
        ensure       => $package_repo_ensure,
        location     => 'https://download.newrelic.com/infrastructure_agent/linux/apt',
        release      => $::lsbdistcodename,
        repos        => 'main',
        architecture => 'amd64',
        key          => {
            'id'     => 'A758B3FBCD43BE8D123A3476BB29EE038ECCE87C',
            'source' => 'https://download.newrelic.com/infrastructure_agent/gpg/newrelic-infra.gpg',
        },
        require      => Package['apt-transport-https'],
      }
      # work around necessary to get Puppet and Apt to get along on first run, per ticket open as of this writing
      # https://tickets.puppetlabs.com/browse/MODULES-2190?focusedCommentId=341801&page=com.atlassian.jira.plugin.system.issuetabpanels:comment-tabpanel#comment-341801
      exec { 'newrelic_infra_apt_get_update':
        command     => 'apt-get update',
        cwd         => '/tmp',
        path        => ['/usr/bin'],
        subscribe   => Apt::Source['newrelic_infra-agent'],
        refreshonly => true,
      }
      package { 'newrelic-infra':
        ensure  => $ensure,
        require => Exec['newrelic_infra_apt_get_update'],
      }
    }
    'RedHat', 'CentOS', 'Amazon', 'OracleLinux': {
      if ($::operatingsystem == 'Amazon') {
        $repo_releasever = '6'
      } else {
        $repo_releasever = $::operatingsystemmajrelease
      }
      yumrepo { 'newrelic_infra-agent':
        ensure        => $package_repo_ensure,
        descr         => 'New Relic Infrastructure',
        baseurl       => "https://download.newrelic.com/infrastructure_agent/linux/yum/el/${repo_releasever}/x86_64",
        gpgkey        => 'https://download.newrelic.com/infrastructure_agent/gpg/newrelic-infra.gpg',
        gpgcheck      => true,
        repo_gpgcheck => $repo_releasever != '5',
      }
      package { 'newrelic-infra':
        ensure  => $ensure,
        require => Yumrepo['newrelic_infra-agent'],
      }
    }
    'OpenSuSE', 'SuSE', 'SLED', 'SLES': {
      # work around necessary because sles has a very old version of puppet and zypprepo can't not be installed
      exec { 'download_newrelic_gpg_key':
        command => '/usr/bin/wget https://download.newrelic.com/infrastructure_agent/gpg/newrelic-infra.gpg -O /opt/newrelic_infra.gpg',
        creates => '/opt/newrelic_infra.gpg',
      } ~>
      exec { 'import_newrelic_gpg_key':
        command    => '/bin/rpm --import /opt/newrelic_infra.gpg',
        refreshonly => true
      } ->
      exec { 'add_newrelic_repo':
        creates => '/etc/zypp/repos.d/newrelic-infra.repo',
        command => "/usr/bin/zypper addrepo --repo http://download.newrelic.com/infrastructure_agent/linux/zypp/sles/${::operatingsystemrelease}/x86_64/newrelic-infra.repo",
        path    => ['/usr/local/sbin', '/usr/local/bin', '/sbin', '/bin', '/usr/bin'],
      }
      # work around necessary because pacakge doesn't have Zypp provider in the puppet SLES version

      if $ensure in ['present', 'latest'] {
        exec { 'install_newrelic_agent':
          command     => '/usr/bin/zypper install -y newrelic-infra',
          path        => ['/usr/local/sbin', '/usr/local/bin', '/sbin', '/bin', '/usr/bin'],
          require     => Exec['add_newrelic_repo'],
          unless => "/bin/rpm -qa | /usr/bin/grep newrelic-infra"
        }
      }
      elsif $ensure == 'absent' {
        exec { "install_newrelic_agent":
          command => "/usr/bin/zypper remove -y newrelic-infra",
          path    => ['/usr/local/sbin', '/usr/local/bin', '/sbin', '/bin', '/usr/bin'],
          onlyif  => "/bin/rpm -qa | /usr/bin/grep newrelic-infra"
        }
      }
    }
    'windows': {
      # download the new relic infrastructure msi file
      file { 'download_newrelic_agent':
        ensure => file,
        path   => 'C:\users\Administrator\Downloads\newrelic-infra.msi',
        source => 'https://download.newrelic.com/infrastructure_agent/windows/newrelic-infra.msi',
      }

      package { 'newrelic-infra':
        ensure   => 'installed',
        name     => 'New Relic Infrastructure Agent',
        source   => 'C:\users\Administrator\Downloads\newrelic-infra.msi',
        require  => File['download_newrelic_agent'],
        provider => $windows_provider,
      }
    }
    default: {
      fail('New Relic Infrastructure agent is not yet supported on this platform')
    }
  }

  if $::operatingsystem != 'windows' {
    # Setup agent config
    file { '/etc/newrelic-infra.yml':
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      content => template('newrelic_infra/newrelic-infra.yml.erb'),
      notify  => Service['newrelic-infra'] # Restarts the agent service on config changes
    }
  }
  else {
    file { 'newrelic_config_file':
      ensure  => file,
      name    => 'C:\Program Files\New Relic\newrelic-infra\newrelic-infra.yml',
      content => template('newrelic_infra/newrelic-infra.yml.erb'),
      require => Package['newrelic-infra'],
      notify  => Service['newrelic-infra'], # Restarts the agent service on config changes
    }
  }

  # we use Upstart on CentOS 6 systems and derivatives, which is not the default
  if (($::operatingsystem == 'CentOS' or $::operatingsystem == 'RedHat')and $::operatingsystemmajrelease == '6')
  or ($::operatingsystem == 'Amazon') {
    service { 'newrelic-infra':
      ensure   => $service_ensure,
      provider => 'upstart',
      require  => Package['newrelic-infra'],
    }
  } elsif $::operatingsystem == 'SLES' {
    # Setup agent service for sysv-init service manager
    service { 'newrelic-infra':
      ensure  => $service_ensure,
      start   => '/etc/init.d/newrelic-infra start',
      stop    => '/etc/init.d/newrelic-infra stop',
      status  => '/etc/init.d/newrelic-infra status',
      require => Exec['install_newrelic_agent']
    }
  } else {
    # Setup agent service
    service { 'newrelic-infra':
      ensure  => $service_ensure,
      require => Package['newrelic-infra'],
    }
  }
}
