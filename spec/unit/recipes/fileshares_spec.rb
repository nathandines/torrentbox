# Cookbook:: torrentbox
# Spec:: fileshares
#
# Copyright:: 2018, Nathan Dines, All Rights Reserved.

require 'spec_helper'

describe 'torrentbox::fileshares' do
  context 'When all attributes are default, on Debian 9.4' do
    let(:chef_run) do
      # for a complete list of available platforms and versions see:
      # https://github.com/customink/fauxhai/blob/master/PLATFORMS.md
      runner = ChefSpec::ServerRunner.new(
        step_into: ['samba_server'],
        platform: 'debian',
        version: '9.4'
      )
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'installs `samba`' do
      expect(chef_run).to install_package('samba')
    end
  end
end
