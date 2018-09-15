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

    it 'includes `torrentbox::netconfig` recipe' do
      expect(chef_run).to include_recipe('torrentbox::netconfig')
    end

    it 'includes `torrentbox::dnsmasq` recipe' do
      expect(chef_run).to include_recipe('torrentbox::dnsmasq')
    end

    it 'includes `torrentbox::system_services` recipe' do
      expect(chef_run).to include_recipe('torrentbox::system_services')
    end

    it 'includes `torrentbox::iptables` recipe' do
      expect(chef_run).to include_recipe('torrentbox::iptables')
    end
  end
end
