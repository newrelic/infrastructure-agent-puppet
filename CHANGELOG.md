# newrelic-infra Puppet module CHANGELOG

# 0.11.0 (2021-05-06)

IMPROVEMENTS:

* Conforming to pdk standard for modules
* Added `download_proxy` for downloading package. (Introduces new module dependency of `lwf-remote_file`)
* Add support for optional MSI download url via `windows_download_url`

BUG FIXES:

* Fixed Windows uninstall issue if service is enabled.

## 0.10.2 (2021-05-05)

BUG FIXES:

* Fixed Windows package "ensure" value to exclude 'latest'.

## 0.10.1 (2021-05-05)

IMPROVEMENTS:

* Removed obsolete future_parser. 

BUG FIXES:

* Fixed Windows package "ensure" value.

## 0.10.0 (2019-08-12)

IMPROVEMENTS:

* Add support for optional MSI installation directory parameter for downloaded windows installation file.  
* The requirements modules has been updated for `puppet-labs-apt` module, This update changed the depencies requirement version of this module from `>= 2.3.0 < 5.0.0` version to `>= 2.3.0 < 8.0.0`. And for `puppetlabs-stdlib` module, the requirements version has been updated from `>= 4.2.0 < 5.0.0` version to `>= 4.2.0 < 7.0.0`.

## 0.9.0 (2019-05-27)

IMPROVEMENTS:

* Add support for installing the agent in different linux architecture from the
  tarballs. For this purppose two new attributes were added
  `newrelic_infra::agent`, `linux_provider` and `tarball_version`.

## 0.8.3 (2019-04-17)

BUG FIXES:

* Add missing `@` in template 

## 0.8.2 (2019-04-16)

BUG FIXES:

* Change the `to_yaml` function for and explicit loop over the `custom_configs`
  attribute, that way avoiding extra trailing whitespaces in the resulting 
  yaml that caused the config options being ignored.

## 0.8.1 (2019-04-12)

BUG FIXES:

* Fixes duplicate creation of newrelic infra repo when using both the agent
  and integrations module.
* Fixes and issue with `apt` based systems where the first execution of the 
  puppet module would fail with `apt` related errors.

## 0.8.0 (2019-04-08)

IMPROVEMENTS:

* Add support for installing individual integrations. The role 
  switches from the deprecated `newrelic-infra-integrations` package (which 
  only included 5 integrations), to the `nri-*` individual integration 
  packages. The `newrelic_infra::integrations` `ensure` parameter was removed, 
  a new `integrations` parameter was added for specifying individual 
  integrations. 

## 0.7.1 (2019-01-14)

IMPROVEMENTS:

BUG FIXES:

* Fix installation in Windows when the default provider for puppet was
  set to something different than `windows`. Now the provider for
  installing the package can be specify with `windows_provider`, when
  not set, it defaults to `windows`

## 0.7.0 (2018-11-16)

IMPROVEMENTS:

* Add Support for Centos 5

## 0.6.1 (2018-11-08)

BUG FIXES:

* Specify correct version in metadata.json

## 0.6.0 (2018-11-02)

IMPROVEMENTS:

* Add Support for Ubuntu 18.04 (bionic)
* Add Support for Windows

## 0.5.1 (2018-06-04)

BUG FIXES:

* Use Upstart for RHEL 6 and Amazon

## 0.5.0 (2018-05-23)

IMPROVEMENTS:

* Add `custom_configs` option

## 0.4.0 (2018-05-16)

IMPROVEMENTS:

* Prevent failure on Oracle Linux

## 0.3.1 (2018-02-25)

IMPROVEMENTS:

* Add syntax checking to Rake tasks
* Update version compatibility metadata

## 0.3.0 (2018-02-23)

IMPROVEMENTS:

* Change name from `newrelic-infra` to `newrelic-newrelic_infra` in manifest.json
* Specify upper limit to Puppet version in manifest.json
* Specify upper limit to dependencies in manfiest.json
* Add metadata-json-lint to lint metadata.json
* Add Rakefile and Rake tasks for linting
* Add SLES support

## 0.2.0 (2018-02-09)

IMPROVEMENTS:

* Change name from `newrelic_infra` to `newrelic-infra` in manifest.json
* Add Travis CI
* Add puppet-lint

## 0.1.0 (2017-11-27)

IMPROVEMENTS:

* A CHANGELOG
* Updated version information
* Simplified test kitchen setup
