require 'metadata-json-lint/rake_task'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

MetadataJsonLint.options.strict_license = false

PuppetLint::RakeTask.new :lint do |config|
  config.disable_checks = ['autoloader_layout']
  config.ignore_paths = ['vendor/**/*.pp']
end

PuppetSyntax.exclude_paths = ['vendor/**/*']

task default: [:lint, :metadata_lint, :syntax]
