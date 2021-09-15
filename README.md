[![New Relic Community Plus header](https://raw.githubusercontent.com/newrelic/open-source-office/master/examples/categories/images/Community_Plus.png)](https://opensource.newrelic.com/oss-category/#community-plus)

![run_tests](https://github.com/newrelic/infrastructure-agent-puppet/actions/workflows/main.yml/badge.svg?branch=master) ![release_puppet](https://github.com/newrelic/infrastructure-agent-puppet/actions/workflows/release.yml/badge.svg)

# Puppet module for the New Relic infrastructure agent

This Puppet module installs and configures the [New Relic infrastructure agent](https://docs.newrelic.com/docs/infrastructure/install-configure-manage-infrastructure) and [on-host integrations](https://docs.newrelic.com/docs/integrations/host-integrations/host-integrations-list/).

## Install and use the Puppet module

### What the `newrelic-infra` Puppet module affects

* Adds the New Relic Infrastructure package repository source.
* Installs and configures the New Relic Infrastructure agent.

### Getting started with `newrelic-infra`

Start by declaring the main `::agent` class.

### Usage

All interactions with `newrelic-infra` are done through the main `agent` class.

#### Install the infrastructure agent

Use the following snippet to install the infrastructure agent:

```ruby
class { 'newrelic_infra::agent':
    ensure      => 'latest',
    license_key => 'YOUR_LICENSE_KEY',
}
```

## Reference

### Classes

#### Public classes

* [`newrelic_infra::agent`](#newrelic_infraagent): Installs and configures the Infrastructure agent.

### `newrelic_infra::agent`

#### Parameters

##### `ensure`

Specifies the Infrastructure agent `ensure` status.

Supported values include:

* `'latest'` - (default) Installs the latest agent version.
* `'absent'` - Uninstalls the agent.
* `string` - String containing a specific version to pin

##### `license_key`

Specifies the New Relic license key to use.

##### `display_name` (Optional)

Overrides the auto-generated hostname for reporting.

##### `verbose` (Optional)

Enables verbose logging for the agent when the value is set to 1. Default value is 0.

##### `log_file` (Optional)

To log to another location, provide a full path and file name. When not set, the agent logs to the system log files.

Typical default locations:

* Amazon Linux, CentOS, RHEL: `/var/log/messages`
* Debian, Ubuntu: `/var/log/syslog`
* Windows Server: `C:\Program Files\New Relic\newrelic-infra\newrelic-infra.log`

##### `proxy` (Optional)

Sets the proxy server the agent should use. Examples:

* `https://myproxy.foo.com:8080`
* `http://10.10.254.254`

##### `custom_attributes` (Optional)

A hash of custom attributes to annotate the data from this agent instance.

##### `custom_configs` (Optional)

A hash of agent configuration directives that are not exposed explicitly. Example:

`{'payload_compression' => 0, 'selinux_enable_semodule' => false}`

##### `windows_provider` (Optional)

Allows for the selection of a provider other than `windows` for the [Windows MSI install](https://docs.newrelic.com/docs/infrastructure/install-configure-manage-infrastructure/windows-installation/install-infrastructure-windows-server-using-msi-installer). Or allows the Windows provider to be used if another provider such as Chocolatey has been specified as default in the Puppet installation.

 ##### `windows_temp_folder` (Optional)

A string value for the temporary folder to download and install the MSI windows installation file. Example:

```
windows_temp_folder => 'C:/Windows/Temp'
```

##### `package_repo_ensure` (Optional)

A flag for omitting the New Relic package repo. Meant for environments where the `newrelic-infra` package has been mirrored to another repo that's already present on the system (set it to `absent` to achieve this).

##### `manage_repo` (Optional)

A flag to prevent conflicts when using mirrors. Applicable for Ubuntu, Debian, RedHat, CentOS, Amazon, OracleLinux

### Installing the infrastructure on-host integrations

In order to install integrations you can use the `integrations` class. The list of available integrations can be found [here][3].

The `newrelic_infra::integrations`, has a parameter named `integrations` which should be a hash of:

```
{
  '<integration_package>' => { ensure => <state> },
  ...
}
```

The integrations package name is located in the **Install and activate** section of the [individual integrations docs](https://docs.newrelic.com/docs/integrations). As a convention, their name is the name of the service with the nri- prefix (`nri-apache`, `nri-redis`, etc.).

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

#### Removing `newrelic-infra-integrations` package and its bundled integrations

> This only applies if you have the `newrelic-infra-integrations` package installed

If you want to remove the `newrelic-infra-integrations` package or any of the bundled integrations (nri-redis, nri-cassandra, nri-apache, nri-nginx, nri-mysql),  add `newrelic-infra-integrations` as the first item of the `integrations` hash argument with an `ensure => absent`.

```ruby
class { 'newrelic_infra::integrations':
  integrations => {
    'newrelic-infra-integrations' => { ensure => absent },
    'nri-mysql'                   => { ensure => absent },
    'nri-redis'                   => { ensure => latest },
  }
}
```

Otherwise, you might get the following error:

```
Error: Execution of '/bin/rpm -e nri-mysql-1.1.5-1.x86_64' returned 1: error: Failed dependencies:
        nri-mysql is needed by (installed) newrelic-infra-integrations-0:1.7.0-1.x86_64
```

That is because the `newrelic-infra-integrations` has a dependency on those packages, so you need to remove it before removing any of the others.

## Compatibility

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

## Support

Should you need assistance with New Relic products, you are in good hands with several support diagnostic tools and support channels.

If the issue has been confirmed as a bug or is a feature request, file a GitHub issue.

**Support Channels**

* [New Relic Documentation](https://docs.newrelic.com): Comprehensive guidance for using our platform
* [New Relic Community](https://discuss.newrelic.com/c/support-products-agents/new-relic-infrastructure): The best place to engage in troubleshooting questions
* [New Relic Developer](https://developer.newrelic.com/): Resources for building a custom observability applications
* [New Relic University](https://learn.newrelic.com/): A range of online training for New Relic users of every level
* [New Relic Technical Support](https://support.newrelic.com/) 24/7/365 ticketed support. Read more about our [Technical Support Offerings](https://docs.newrelic.com/docs/licenses/license-information/general-usage-licenses/support-plan).

## Privacy

At New Relic we take your privacy and the security of your information seriously, and are committed to protecting your information. We must emphasize the importance of not sharing personal data in public forums, and ask all users to scrub logs and diagnostic information for sensitive information, whether personal, proprietary, or otherwise.

We define “Personal Data” as any information relating to an identified or identifiable individual, including, for example, your name, phone number, post code or zip code, Device ID, IP address, and email address.

For more information, review [New Relic’s General Data Privacy Notice](https://newrelic.com/termsandconditions/privacy).

## Contribute

We encourage your contributions to improve this project! Keep in mind that when you submit your pull request, you'll need to sign the CLA via the click-through using CLA-Assistant. You only have to sign the CLA one time per project.

If you have any questions, or to execute our corporate CLA (which is required if your contribution is on behalf of a company), drop us an email at opensource@newrelic.com.

**A note about vulnerabilities**

As noted in our [security policy](../../security/policy), New Relic is committed to the privacy and security of our customers and their data. We believe that providing coordinated disclosure by security researchers and engaging with the security community are important means to achieve our security goals.

If you believe you have found a security vulnerability in this project or any of New Relic's products or websites, we welcome and greatly appreciate you reporting it to New Relic through [HackerOne](https://hackerone.com/newrelic).

If you would like to contribute to this project, review [these guidelines](./CONTRIBUTING.md).

To all contributors, we thank you!  Without your contribution, this project would not be what it is today.

## License

infrastructure-agent-puppet is licensed under the [Apache 2.0](http://apache.org/licenses/LICENSE-2.0.txt) License.

[1]: https://forge.puppet.com/newrelic/newrelic_infra
[2]: https://travis-ci.org/newrelic/infrastructure-agent-puppet/
[3]: https://docs.newrelic.com/docs/integrations/host-integrations/host-integrations-list
[4]: https://github.com/search?l=&p=1&q=nri-+user%3Anewrelic&ref=advsearch&type=Repositories&utf8=%E2%9C%93
