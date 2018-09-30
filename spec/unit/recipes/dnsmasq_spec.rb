#
# Cookbook:: torrentbox
# Spec:: dnsmasq
#
# Copyright:: 2018, Nathan Dines, All Rights Reserved.

require 'spec_helper'

describe 'torrentbox::dnsmasq' do
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

    it 'installs `dnsmasq`' do
      expect(chef_run).to install_package('dnsmasq')
    end

    it 'configures `dnsmasq`' do
      expect(chef_run).to create_template('/etc/dnsmasq.conf').with(
        variables: {
          local_dns:    %w(8.8.8.8 8.8.4.4),
          vpn_dns:      %w(1.1.1.1 1.0.0.1),
          vpn_domain:   'privateinternetaccess.com',
        },
        owner: 'root',
        group: 'root',
        mode: '0644'
      )
    end

    it 'reloads the `dnsmasq` service on reconfiguration' do
      expect(chef_run.template('/etc/dnsmasq.conf'))
        .to notify('service[dnsmasq]')
        .to(:restart).immediately
    end

    it 'enable the `dnsmasq` service' do
      expect(chef_run).to enable_service('dnsmasq')
    end

    it 'start the `dnsmasq` service' do
      expect(chef_run).to start_service('dnsmasq')
    end
  end
end
