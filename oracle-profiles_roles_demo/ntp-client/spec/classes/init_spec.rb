# Lucian Maly <lucian.maly@oracle.com>

require 'spec_helper'

describe 'ntp' do
  context 'with defaults for all parameters' do
    it { should contain_class('ntp') }
  end

  context 'The file expected to have these settings' do
    it do
	is_expected.to contain_file('/etc/ntp.conf').with({
     	'ensure' => 'file',
     	'owner'  => '0',
     	'group'  => '0',
     	'mode'   => '0644',
     	})
  	end
  end
end
