#
# Cookbook:: torrentbox
# Spec:: openvpn
#
# Copyright:: 2018, Nathan Dines, All Rights Reserved.

require 'spec_helper'

describe 'torrentbox::openvpn' do
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

    it 'installs `openvpn`' do
      expect(chef_run).to install_package('openvpn')
    end

    it 'configures `openvpn`' do
      expect(chef_run).to create_template('/etc/openvpn/client.conf').with(
        variables: {
          server: 'swiss.privateinternetaccess.com',
        },
        owner: 'root',
        group: 'root',
        mode: '0644'
      )
    end

    it 'reloads the `openvpn@client` service on reconfiguration' do
      expect(chef_run.template('/etc/openvpn/client.conf'))
        .to notify('service[openvpn@client]')
        .to(:restart).delayed
    end

    it 'configures credentials for `openvpn`' do
      expect(chef_run).to create_file('/etc/openvpn/credentials').with(
        content: "username_undefined\npassword_undefined",
        owner: 'root',
        group: 'root',
        mode: '0600',
        sensitive: true
      )
    end

    it 'reloads the `openvpn@client` service on credential change' do
      expect(chef_run.file('/etc/openvpn/credentials'))
        .to notify('service[openvpn@client]')
        .to(:restart).delayed
    end

    it 'enable the `openvpn@client` service' do
      expect(chef_run).to enable_service('openvpn@client')
    end

    it 'start the `openvpn@client` service' do
      expect(chef_run).to start_service('openvpn@client')
    end
  end
end
