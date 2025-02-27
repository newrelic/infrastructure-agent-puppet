# == Class: newrelic_infra::agent
#
# === Required Parameters
# [*ensure*]
#   Infrastructure agent version ('absent' will uninstall). When using
#   `linux_provider='tarball'` this takes no effect.
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
# [*manage_repo*]
#   Optionally disable creating any of the repo resources and control outside
#   of this module.
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
# [*windows_temp_folder*]
#   Optional. A string value for the temporary folder to download and install the MSI windows installation file.
#
# [*download_proxy*]
#   Optional. Proxy url for tarball or msi install
#
# [*windows_download_url*]
#   Optional. A string value for the *base* download URL for MSI windows installation file.
#
# [*linux_provider*]
#   Specifies the provider to use for installing the agent. Two options are
#   supported:
#   - `package_manager` (default): installs from the underlying package
#   manager the linux distro uses (yum, zypp or apt).
#   - `tarball`: downloads a newrelic tarball from
#   https://download.newrelic.com/infrastructure_agent/test/binaries/linux/
#   and installs the version specified with `$tarball_version`. This options
#   can be used in systems with distros/architectures that are not officially
#   supported. Refer to the link above for a list of the available tarballs
#   for each architecture.
#
# [*tarball_version*]
#   Linux only. The version of the tarball agent to install specied as `'major.minor.patch'`,
#   for example `1.3.18`, the architecture would be retrieved from the
#   `'os'.'architecture'` fact. This attribute only applies when using
#   `linux_provider='tarball'`
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
  $manage_repo          = true,
  $proxy                = '',
  $display_name         = '',
  $verbose              = '',
  $log_file             = '',
  $custom_attributes    = {},
  $custom_configs       = {},
  $download_proxy       = undef,
  $windows_provider     = 'windows',
  $windows_temp_folder  = 'C:/Windows/Temp',
  $windows_download_url = 'https://download.newrelic.com/infrastructure_agent/windows',
  $linux_provider       = 'package_manager',
  $tarball_version      = undef
) {
  # Validate license key
  if $license_key == '' {
    fail('New Relic license key not provided')
  }

  # When ensure is absent, ensure that other variables are set for removal as well
  if $ensure == 'absent' {
    $package_repo_state = 'absent'
    $service_state = 'stopped'
  } else {
    $package_repo_state = $package_repo_ensure
    $service_state = $service_ensure
  }

  case $facts['kernel'] {
    'Linux': {
      case $linux_provider {
        'package_manager': {
          # Setup agent package repo
          case $facts['os']['name'] {
            'Debian', 'Ubuntu': {
              ensure_packages('apt-transport-https')
              if $manage_repo {
                apt::source { 'newrelic_infra-agent':
                  ensure       => $package_repo_state,
                  location     => 'https://download.newrelic.com/infrastructure_agent/linux/apt',
                  release      => $::lsbdistcodename,
                  repos        => 'main',
                  architecture => 'amd64',
                  key          => {
                      'id'     => 'A758B3FBCD43BE8D123A3476BB29EE038ECCE87C',
                      'source' => 'https://download.newrelic.com/infrastructure_agent/keys/newrelic_apt_key_current.gpg',
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
                  before      => Package['newrelic-infra'],
                  refreshonly => true,
                }
              }
              package { 'newrelic-infra':
                ensure  => $ensure,
              }
            }
            'RedHat', 'CentOS', 'Amazon', 'OracleLinux', 'AlmaLinux': {
              if ($::operatingsystem == 'Amazon' and $::operatingsystemmajrelease == '2018'){
                $repo_releasever = '6'
              } elsif ($::operatingsystem == 'Amazon' and $::operatingsystemmajrelease == '2'){
                $repo_releasever = '7'
              } else {
                $repo_releasever = $::operatingsystemmajrelease
              }
              if $manage_repo {
                yumrepo { 'newrelic_infra-agent':
                  ensure        => $package_repo_state,
                  descr         => 'New Relic Infrastructure',
                  baseurl       => "https://download.newrelic.com/infrastructure_agent/linux/yum/el/${repo_releasever}/x86_64",
                  gpgkey        => 'https://download.newrelic.com/infrastructure_agent/keys/newrelic_rpm_key_current.gpg',
                  gpgcheck      => true,
                  repo_gpgcheck => $repo_releasever != '5',
                  before        =>  Package['newrelic-infra'],
                }
              }
              package { 'newrelic-infra':
                ensure  => $ensure,
              }
            }
            'OpenSuSE', 'SuSE', 'SLED', 'SLES': {
              # work around necessary because sles has a very old version of puppet and zypprepo can't not be installed
              exec { 'download_newrelic_gpg_key':
                command => '/usr/bin/wget https://download.newrelic.com/infrastructure_agent/keys/newrelic_rpm_key_current.gpg -O /opt/newrelic_infra.gpg',
                creates => '/opt/newrelic_infra.gpg',
              }
              ~> exec { 'import_newrelic_gpg_key':
                command     => '/bin/rpm --import /opt/newrelic_infra.gpg',
                refreshonly => true
              }
              -> exec { 'add_newrelic_repo':
                creates => '/etc/zypp/repos.d/newrelic-infra.repo',
                command => "/usr/bin/zypper addrepo --repo https://download.newrelic.com/infrastructure_agent/linux/zypp/sles/${::operatingsystemrelease}/x86_64/newrelic-infra.repo",
                path    => ['/usr/local/sbin', '/usr/local/bin', '/sbin', '/bin', '/usr/bin'],
              }
              # work around necessary because pacakge doesn't have Zypp provider in the puppet SLES version

              if $ensure in ['present', 'latest'] {
                exec { 'install_newrelic_agent':
                  command => '/usr/bin/zypper install -y newrelic-infra',
                  path    => ['/usr/local/sbin', '/usr/local/bin', '/sbin', '/bin', '/usr/bin'],
                  require => Exec['add_newrelic_repo'],
                  unless  => '/bin/rpm -qa | /usr/bin/grep newrelic-infra'
                }
              }
              elsif $ensure == 'absent' {
                exec { 'install_newrelic_agent':
                  command => '/usr/bin/zypper remove -y newrelic-infra',
                  path    => ['/usr/local/sbin', '/usr/local/bin', '/sbin', '/bin', '/usr/bin'],
                  onlyif  => '/bin/rpm -qa | /usr/bin/grep newrelic-infra'
                }
              }
            }
            default: {
              fail('New Relic Infrastructure agent is not yet supported on this platform')
            }
          }
        }
        'tarball': {
          if !$tarball_version {
            fail("The `tarball_version` variable should be defined when using `linux_provider='tarball'`")
          }

          case $facts['os']['architecture'] {
            'x86_64': { $arch = 'amd64' }
            'i386': { $arch = '386' }
            default: { $arch = facts['os']['architecture'] }
          }
          $tar_filename = "newrelic-infra_linux_${tarball_version}_${arch}.tar.gz"
          $target_dir = "/opt/newrelic_infra/linux_${tarball_version}_${arch}"

          file { '/opt/newrelic_infra':
            ensure => directory
          }
          -> file { $target_dir:
            ensure => directory
          }

          remote_file { 'download_newrelic_agent':
            ensure => present,
            path   => "/opt/${tar_filename}",
            source => "https://download.newrelic.com/infrastructure_agent/binaries/linux/${arch}/${tar_filename}",
            proxy  => $download_proxy
          }

          exec { 'uncompress newrelic-infra tarball':
            command => "tar -xzf /opt/${tar_filename} -C ${target_dir} ",
            path    => '/bin',
            creates => "${target_dir}/newrelic-infra/",
            require => Remote_file[
              'download_newrelic_agent',
              $target_dir
            ]
          }
          ~> exec { 'run installation script':
            command     => "${target_dir}/newrelic-infra/installer.sh",
            provider    => shell,
            cwd         => "${target_dir}/newrelic-infra",
            refreshonly => true,
            environment =>  ["NRIA_LICENSE_KEY=${license_key}"]
          }
          Exec['run installation script'] -> Service['newrelic-infra']
        }
      default: {
        fail('New Relic Infrastructure agent is not yet supported on this platform')
      }
      }
    }
    'windows': {
      if $ensure in ['present', 'latest', 'installed'] {
        $ensure_windows = 'installed'
        $download_windows = 'newrelic-infra.msi'
      } else {
        $ensure_windows = $ensure
        $download_windows = "newrelic-infra.${ensure}.msi"
      }

      # download the new relic infrastructure msi file
      remote_file { 'download_newrelic_agent':
        ensure => present,
        path   => "${windows_temp_folder}/${download_windows}",
        source => "${$windows_download_url}/${download_windows}",
        proxy  => $download_proxy
      }

      package { 'newrelic-infra':
        ensure   => $ensure_windows,
        name     => 'New Relic Infrastructure Agent',
        source   => "${windows_temp_folder}/${download_windows}",
        require  => Remote_file['download_newrelic_agent'],
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
    if $ensure == 'absent' {
      file { 'newrelic_config_file':
        ensure => 'absent',
        name   => 'C:\Program Files\New Relic\newrelic-infra\newrelic-infra.yml'
      }
    } else {
      file { 'newrelic_config_file':
        ensure  => file,
        name    => 'C:\Program Files\New Relic\newrelic-infra\newrelic-infra.yml',
        content => template('newrelic_infra/newrelic-infra.yml.erb'),
        require => Package['newrelic-infra'],
        notify  => Service['newrelic-infra'], # Restarts the agent service on config changes
      }
    }
  }

  # we use Upstart on CentOS 6 systems and derivatives, which is not the default
  if (($::operatingsystem == 'CentOS' or $::operatingsystem == 'RedHat' or $::operatingsystem == 'OracleLinux')and $::operatingsystemmajrelease == '6')
  or ($::operatingsystem == 'Amazon' and $::operatingsystemmajrelease == '2018') {
    service { 'newrelic-infra':
      ensure   => $service_state,
      provider => 'upstart',
    }
  } elsif $::operatingsystem == 'SLES' and $::operatingsystemmajrelease == '12' {
    # Setup agent service for systemd service manager
    service { 'newrelic-infra':
      ensure => $service_ensure,
      start  => 'systemctl start newrelic-infra',
      stop   => 'systemctl stop newrelic-infra',
      status => 'systemctl status newrelic-infra',
    }
  } elsif $::operatingsystem == 'SLES' and $::operatingsystemmajrelease == '11' {
    # Setup agent service for sysv-init service manager
    service { 'newrelic-infra':
      ensure => $service_state,
      start  => '/etc/init.d/newrelic-infra start',
      stop   => '/etc/init.d/newrelic-infra stop',
      status => '/etc/init.d/newrelic-infra status',
    }
  } else {
    # Setup agent service
    if $ensure == 'absent' {
      service { 'newrelic-infra':
        ensure => stopped,
        enable => false
      }
    } else {
      service { 'newrelic-infra':
        ensure => $service_state,
        enable => true
      }
    }
  }
}
