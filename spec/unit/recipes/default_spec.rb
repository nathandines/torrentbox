#
# Cookbook:: torrentbox
# Spec:: default
#
# Copyright:: 2018, Nathan Dines, All Rights Reserved.

require 'spec_helper'

describe 'torrentbox::default' do
  context 'When all attributes are default, on an Debian 9.4' do
    let(:chef_run) do
      # for a complete list of available platforms and versions see:
      # https://github.com/customink/fauxhai/blob/master/PLATFORMS.md
      runner = ChefSpec::ServerRunner.new(platform: 'debian', version: '9.4')
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    cookbook_recipes = %w(
      dnsmasq
      iptables
      netconfig
      openvpn
      remote_access
      system_services
      transmission
      fileshares
    )

    cookbook_recipes.each do |recipe|
      it "includes `torrentbox::#{recipe}` recipe" do
        expect(chef_run).to include_recipe("torrentbox::#{recipe}")
      end
    end
  end

  context 'With the VPN disabled, on an Debian 9.4' do
    let(:chef_run) do
      # for a complete list of available platforms and versions see:
      # https://github.com/customink/fauxhai/blob/master/PLATFORMS.md
      runner = ChefSpec::ServerRunner.new(platform: 'debian', version: '9.4')
      runner.node.override['torrentbox']['vpn_enabled'] = false
      runner.converge(described_recipe)
    end

    it 'must not include `torrentbox::openvpn` recipe' do
      expect(chef_run).to_not include_recipe('torrentbox::openvpn')
    end
  end
end
