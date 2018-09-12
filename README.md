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

##### `package_repo_ensure`

Optional. A flag for omitting the New Relic package repo. Meant for environments where the `newrelic-infra`
package has been mirrored to another repo that's already present on the system (set to `absent` to achieve this)

### Installing the Infrastructure integrations

In order to install `newrelic-infra-integrations` package you can use the main `integrations` class.

```ruby
class { 'newrelic_infra::integrations':
}
```

## Limitations

### Platforms

* Amazon Linux all versions
* CentOS version 6 or higher
* Debian version 7 ("Wheezy") or higher
* Red Hat Enterprise Linux (RHEL) version 6 or higher
* Ubuntu versions 12.04._, 14.04._, and 16.04.\* (LTS versions)

## License

Copyright (c) 2016 New Relic, Inc. All rights reserved.
