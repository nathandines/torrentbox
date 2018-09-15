#
# Cookbook:: torrentbox
# Spec:: default
#
# Copyright:: 2018, Nathan Dines, All Rights Reserved.

require 'spec_helper'

describe 'torrentbox::iptables' do
  context 'When all attributes are default, on an Debian 9.4' do
    let(:chef_run) do
      # for a complete list of available platforms and versions see:
      # https://github.com/customink/fauxhai/blob/master/PLATFORMS.md
      runner = ChefSpec::ServerRunner.new(
        step_into: ['iptables_rule'],
        platform: 'debian',
        version: '9.4'
      )
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'includes `iptables::default` recipe' do
      expect(chef_run).to include_recipe('iptables::default')
    end

    it 'Add VPN Input rules to iptables' do
      expect(chef_run).to create_template('/etc/iptables.d/000_vpninput').with(
        source: 'iptables/000_vpninput.erb',
        variables: {
          transmission_port: 51234,
        }
      )
    end

    it 'Add Ethernet Output rules to iptables' do
      expect(chef_run).to create_template('/etc/iptables.d/100_ethernetoutput').with(
        source: 'iptables/100_ethernetoutput.erb',
        variables: {
          local_dns: %w(
            1.1.1.1
            1.0.0.1
          ),
          destination_whitelist: [],
        }
      )
    end

    it 'Add Input rules to iptables' do
      expect(chef_run).to create_template('/etc/iptables.d/900_input').with(
        source: 'iptables/900_input.erb'
      )
    end

    it 'Add Output rules to iptables' do
      expect(chef_run).to create_template('/etc/iptables.d/900_output').with(
        source: 'iptables/900_output.erb'
      )
    end
  end
end
