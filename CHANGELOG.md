# newrelic-infra Puppet module CHANGELOG

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
