# newrelic-infra Puppet module

[![Build Status](https://travis-ci.org/newrelic/infrastructure-agent-puppet.svg?branch=master)](https://travis-ci.org/newrelic/infrastructure-agent-puppet)

## Description

This module installs and configures the New Relic Infrastructure agent.

## Setup

### What newrelic-infra affects

* Adds the New Relic Infrastructure package repository source
* Installs and configures the New Relic Infrastructure agent

### Beginning with newrelic-infra

Declare the main `::agent` class.

## Usage

All interactions with `newrelic-infra` will be done through the main `agent` class.

### Installing the Infrastructure agent

```ruby
class { 'newrelic_infra::agent':
    ensure      => 'latest',
    license_key => 'YOUR_LICENSE_KEY',
}
```

## Reference

### Classes

#### Public Classes

* [`newrelic_infra::agent`](#newrelic_infraagent): Installs and configures the Infrastructure agent.

### `newrelic_infra::agent`

#### Parameters

##### `ensure`

Specifies the Infrastructure agent ensure status.

Valid values include:

* `'latest'` - (default) Installs the latest agent version
* `'absent'` - Uninstalls the agent
* string - String containing a specific version to pin

##### `license_key`

Specifies the New Relic license key to use.

##### `display_name`

Optional. Override the auto-generated hostname for reporting.

##### `verbose`

Optional. Enables verbose logging for the agent when set the value with 1, the default value is 0.

##### `log_file`

Optional. To log to another location, provide a full path and file name. When not set, the agent logs to the system log files.
Typical default locations:

* Amazon Linux, CentOS, RHEL: `/var/log/messages`
* Debian, Ubuntu: `/var/log/syslog`
* Windows Server: `C:\Program Files\New Relic\newrelic-infra\newrelic-infra.log`

##### `proxy`

Optional. Set the proxy server the agent should use. Examples:

* `https://myproxy.foo.com:8080`
* `http://10.10.254.254`

##### `custom_attributes`

Optional. A hash of custom attributes to annotate the data from this agent instance.

##### `custom_configs`

Optional. A hash of agent configuration directives that are not exposed explicitly. Example:

{'payload_compression' => 0, 'selinux_enable_semodule' => false}

##### `windows_provider`

 Optional. Allows for the selection of a provider other than 'windows' for the Windows MSI install. Or allows the windows provider to be used if another provider such as Chocolatey has been specified as the default provider in the puppet installation.

 ##### `windows_temp_folder`
Optional. A string value for the temporary folder to download and install the MSI windows installation file. Example:

 ```
windows_temp_folder => 'C:/users/Administrator/Downloads'
```

##### `package_repo_ensure`

Optional. A flag for omitting the New Relic package repo. Meant for environments where the `newrelic-infra`
package has been mirrored to another repo that's already present on the system (set to `absent` to achieve this)

### Installing the Infrastructure On-host integrations

In order to install integrations you can use the `integrations` class. The list
of available integrations can be found [here][3].

The `newrelic_infra::integrations`, has a parameter named `integrations` which
should be a hash of:

```
{
  '<integration_package>' => { ensure => <state> },
  ...
}
```

The integrations package name is located in the **Install and activate**
section of the individual integrations docs. They use the following convention,
name of the service with the `nri-` prefix (`nri-apache`, `nri-redis`, ...).

```ruby
class { 'newrelic_infra::integrations':
  integrations => {
    'nri-mysql' => { ensure => present },
    'nri-redis' => { ensure => latest },
    'nri-rabbitmq' => { ensure => absent }
  }
}
```

The source code for each integration is available on [newrelic's github organization][4].

#### Removing newrelic-infra-integrations package and its bundled integrations

**NOTE** *This only applies if you have the `newrelic-infra-integrations` 
package installed*

If you had installed the `newrelic-infra-integrations` package, 
could be because you were using the previous versions of this module, or you 
installed it some other way; and you want to do some cleanup by
removing it or any of the following integrations (the ones that came bundle
with it):

- nri-redis
- nri-cassandra
- nri-apache
- nri-nginx
- nri-mysql

You have to add `newrelic-infra-integrations` as the first item of the 
`integrations` hash argument with an `ensure => absent`.

```ruby
class { 'newrelic_infra::integrations':
  integrations => {
    'newrelic-infra-integrations' => { ensure => absent },
    'nri-mysql'                   => { ensure => absent },
    'nri-redis'                   => { ensure => latest },
  }
}
```

Otherwise you might get the following error:

```
Error: Execution of '/bin/rpm -e nri-mysql-1.1.5-1.x86_64' returned 1: error: Failed dependencies:
        nri-mysql is needed by (installed) newrelic-infra-integrations-0:1.7.0-1.x86_64
```

That is because the `newrelic-infra-integrations`, has a dependency on those 
packages, so you need to remove it first, before removing any of the other.

## Limitations

### Platforms

* Amazon Linux all versions
* CentOS version 5 or higher
* Debian version 7 ("Wheezy") or higher
* Red Hat Enterprise Linux (RHEL) version 5 or higher
* Ubuntu versions 12.04._, 14.04._, 16.04._, and 18.04_ (LTS versions)
* Windows 2008, 2012, 2016 and 2019

## Release to PuppetForge

To release a new version to [PuppetForge][1] follow this steps:

* Update the [CHANGELOG.md](CHANGELOG.md)
* Increase the version in [metadata.json](metadata.json)
* Create a new Github release: the release process will be executed
  in [TravisCI][2]

## License

Copyright (c) 2019 New Relic, Inc. All rights reserved.

[1]: https://forge.puppet.com/newrelic/newrelic_infra
[2]: https://travis-ci.org/newrelic/infrastructure-agent-puppet/
[3]: https://docs.newrelic.com/docs/integrations/host-integrations/host-integrations-list
[4]: https://github.com/search?l=&p=1&q=nri-+user%3Anewrelic&ref=advsearch&type=Repositories&utf8=%E2%9C%93
