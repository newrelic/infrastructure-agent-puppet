class { 'newrelic_infra::agent':
  ensure      => 'latest',
  license_key => 'YOUR_NR_LICENSE_KEY',
}
