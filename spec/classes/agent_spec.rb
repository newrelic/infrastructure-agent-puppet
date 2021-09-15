require 'spec_helper'

describe 'newrelic_infra::agent' do
  let(:params) { { 'license_key' => 'TEST_VALUE' } }
  let(:node_params) { { 'lsbdistcodename' => 'xenial', 'operatingsystem' => 'Ubuntu', 'operatingsystemmajrelease' => '16.04' } }
  let(:facts) 
  do
    {
      'kernel' => 'Linux',
      'os' => {
        'name' => 'Ubuntu',
        'family' => 'Debian',
        'release' => {
            'full' => '16.04',
            'major' => '16.04',
        },
        'distro' => {
            'codename' => 'xenial',
            'description' => 'Ubuntu 16.04 LTS',
            'id' => 'Ubuntu',
            'release' => {
                'full' => '16.04',
                'major' => '16.04'
            }
        },
      }
    }
  end
  it { is_expected.to compile }
end
