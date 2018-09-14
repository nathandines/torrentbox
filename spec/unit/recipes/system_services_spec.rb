#
# Cookbook:: torrentbox
# Spec:: system_services
#
# Copyright:: 2018, Nathan Dines, All Rights Reserved.

require 'spec_helper'

describe 'torrentbox::system_services' do
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

    it 'installs `ntp`' do
      expect(chef_run).to install_package('ntp')
    end

    it 'enable the `ntp` service' do
      expect(chef_run).to enable_service('ntp')
    end

    it 'start the `ntp` service' do
      expect(chef_run).to start_service('ntp')
    end
  end
end
