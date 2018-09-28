#
# Cookbook:: torrentbox
# Spec:: transmission
#
# Copyright:: 2018, Nathan Dines, All Rights Reserved.

require 'spec_helper'

describe 'torrentbox::transmission' do
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

    it 'installs `transmission-daemon`' do
      expect(chef_run).to install_package('transmission-daemon')
    end

    it 'enables the `transmission-daemon` service' do
      expect(chef_run).to enable_service('transmission-daemon')
    end

    it 'starts the `transmission-daemon` service' do
      expect(chef_run).to start_service('transmission-daemon')
    end

    it 'creates the download directory' do
      expect(chef_run).to create_directory('/var/lib/transmission-daemon/downloads').with(
        owner: 'debian-transmission',
        group: 'debian-transmission',
        mode:  '2777'
      )
    end

    it 'creates the torrent watchdir' do
      expect(chef_run).to create_directory('/var/lib/transmission-daemon/torrents').with(
        owner: 'debian-transmission',
        group: 'debian-transmission',
        mode:  '2777'
      )
    end

    it 'configures `transmission-daemon` and sets the file to read-only' do
      expect(chef_run).to create_template('/etc/transmission-daemon/settings.json').with(
        source: 'transmission/settings.json.erb',
        owner: 'debian-transmission',
        group: 'debian-transmission',
        mode:  '0400',
        variables: {
          transmission_port: 51234,
          download_path: '/var/lib/transmission-daemon/downloads',
          torrent_watchdir_path: '/var/lib/transmission-daemon/torrents',
        }
      )
    end

    it 'reloads `transmission-daemon` upon reconfiguration' do
      expect(chef_run.template('/etc/transmission-daemon/settings.json'))
        .to notify('service[transmission-daemon]')
        .to(:reload).delayed
    end
  end
end
