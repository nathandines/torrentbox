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

    it 'configure static IP addressing on the filesystem' do
      expect(chef_run).to create_template('/etc/network/interfaces').with(
        owner: 'root',
        group: 'root',
        mode: '0644',
        source: 'networking/interfaces.erb',
        variables: {
          asymmetric_routing_script: '/usr/local/sbin/asymmetric_routing.sh',
          dynamic_configuration: false,
          ifaddress: '10.0.0.2',
          ifgw: '10.0.0.1',
          ifmask: '255.255.255.0',
          ifname: 'eth0',
        }
      )
    end

    it 'must have a static IP addressing configuration' do
      expect(chef_run).to render_file('/etc/network/interfaces').with_content(
        <<-NETCONFIG.gsub(/^\s{8}/, '')
        # The primary network interface
        auto eth0
        iface eth0 inet static
            address  10.0.0.2
            netmask  255.255.255.0
            gateway  10.0.0.1
            post-up  /usr/local/sbin/asymmetric_routing.sh up 200
            pre-down /usr/local/sbin/asymmetric_routing.sh down 200
        NETCONFIG
      )
    end

    it 'restart the default network interface on reconfiguration' do
      expect(chef_run.template('/etc/network/interfaces'))
        .to notify('execute[reload_network]')
        .to(:run).delayed
    end

    it 'should not reload the network without a trigger' do
      expect(chef_run).to_not run_execute('reload_network')
    end

    it 'has a script to configure asymmetric routing' do
      expect(chef_run).to create_cookbook_file('/usr/local/sbin/asymmetric_routing.sh').with(
        mode: '0755',
        owner: 'root',
        group: 'root',
        source: 'networking/asymmetric_routing.sh'
      )
    end

    it 'reloads the network on an asymmetric routing script change' do
      expect(chef_run.cookbook_file('/usr/local/sbin/asymmetric_routing.sh'))
        .to notify('execute[reload_network]')
        .to(:run).delayed
    end
  end

  context 'with dynamic IP addressing, on an Debian 9.4' do
    let(:chef_run) do
      # for a complete list of available platforms and versions see:
      # https://github.com/customink/fauxhai/blob/master/PLATFORMS.md
      runner = ChefSpec::ServerRunner.new(platform: 'debian', version: '9.4')
      runner.node.normal['torrentbox']['netconfig']['dynamic_configuration'] = true
      runner.converge(described_recipe)
    end

    it 'must have a dynamic IP addressing configuration' do
      expect(chef_run).to render_file('/etc/network/interfaces').with_content(
        <<-NETCONFIG.gsub(/^\s{8}/, '')
        # The primary network interface
        auto eth0
        allow-hotplug eth0
        iface eth0 inet dhcp
            post-up  /usr/local/sbin/asymmetric_routing.sh up 200
            pre-down /usr/local/sbin/asymmetric_routing.sh down 200
        NETCONFIG
      )
    end
  end
end
