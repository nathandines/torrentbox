#
# Cookbook:: torrentbox
# Spec:: netconfig
#
# Copyright:: 2018, Nathan Dines, All Rights Reserved.

require 'spec_helper'

describe 'torrentbox::netconfig' do
  context 'When all attributes are default, on Debian 9.4' do
    let(:chef_run) do
      # for a complete list of available platforms and versions see:
      # https://github.com/customink/fauxhai/blob/master/PLATFORMS.md
      runner = ChefSpec::ServerRunner.new(platform: 'debian', version: '9.4')
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'has IPv6 disabled in sysctl configuration' do
      expect(chef_run).to create_file('/etc/sysctl.d/40-ipv6.conf').with(
        mode: '0644',
        owner: 'root',
        group: 'root',
        content: 'net.ipv6.conf.all.disable_ipv6 = 1'
      )
    end

    it 'reloads the sysctl on reconfiguration' do
      expect(chef_run.file('/etc/sysctl.d/40-ipv6.conf'))
        .to notify('execute[sysctl_refresh]')
        .to(:run).delayed
    end

    it 'should not execute `sysctl_refresh` without a trigger' do
      expect(chef_run).to_not run_execute('sysctl_refresh')
    end
  end
end
