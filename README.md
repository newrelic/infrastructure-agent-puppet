# newrelic-infra

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with newrelic-infra](#setup)
    * [What newrelic-infra affects](#what-newrelic-infra-affects)
    * [Beginning with newrelic-infra](#beginning-with-newrelic-infra)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)

## Description

This module installs and configures the New Relic Infrastructure agent.

## Setup

### What newrelic-infra affects

- Adds the New Relic Infrastructure package repository source
- Installs and configures the New Relic Infrastructure agent

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

##### `proxy`

Optional. Set the proxy server the agent should use. Examples:
- `https://myproxy.foo.com:8080`
- `http://10.10.254.254`

##### `custom_attributes`

Optional. A hash of custom attributes to annotate the data from this agent instance.

##### `package_repo_ensure`

Optional. A flag for omitting the New Relic package repo. Meant for environments where the `newrelic-infra`
package has been mirrored to another repo that's already present on the system (set to `absent` to achieve this)

## Limitations

### Platforms

- RHEL
  - CentOS 7
  - CentOS 6
- Ubuntu
  - 16 Xenial
  - 14 Trusty
  - 12 Precise
- Debian
  - 10 Buster
  - 9 Stretch
  - 8 Jessie
  - 7 Wheezy

Copyright (c) 2016 New Relic, Inc. All rights reserved.
