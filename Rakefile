require 'metadata-json-lint/rake_task'
require 'puppet-lint/tasks/puppet-lint'

MetadataJsonLint.options.strict_license = false

PuppetLint::RakeTask.new :lint do |config|
  config.disable_checks = ['autoloader_layout']
  config.ignore_paths = ['vendor/**/*.pp']
end

task default: [:lint, :metadata_lint]
