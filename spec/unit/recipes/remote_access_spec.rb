#
# Cookbook:: torrentbox
# Spec:: remote_access
#
# Copyright:: 2018, Nathan Dines, All Rights Reserved.

require 'spec_helper'

describe 'torrentbox::remote_access' do
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

    %w(tigervnc-standalone-server openbox dbus-x11 fonts-dejavu firefox-esr).each do |package_name|
      it "installs `#{package_name}`" do
        expect(chef_run).to install_package(package_name)
      end
    end

    it 'creates a remote access user `torrentbox`' do
      expect(chef_run).to create_user('torrentbox').with(
        comment: 'User for torrentbox remote access',
        manage_home: true,
        shell: '/usr/sbin/nologin',
        home: '/home/torrentbox'
      )
    end

    it 'the general user configuration directory `~torrentbox/.config`' do
      expect(chef_run).to create_directory('/home/torrentbox/.config').with(
        owner: 'torrentbox',
        group: 'torrentbox',
        mode: '0755'
      )
    end

    it 'the openbox configuration directory `~torrentbox/.config/openbox`' do
      expect(chef_run).to create_directory('/home/torrentbox/.config/openbox').with(
        owner: 'torrentbox',
        group: 'torrentbox',
        mode: '0755'
      )
    end

    it 'configures openbox `~torrentbox/.config/openbox/rc.xml`' do
      expect(chef_run).to create_cookbook_file('/home/torrentbox/.config/openbox/rc.xml').with(
        source: 'openbox/rc.xml',
        owner: 'torrentbox',
        group: 'torrentbox',
        mode: '0644'
      )
    end

    it 'restarts the `vncserver@:1` service on openbox config change' do
      expect(chef_run.cookbook_file('/home/torrentbox/.config/openbox/rc.xml'))
        .to notify('service[vncserver@:1]')
        .to(:restart).delayed
    end

    it 'the vncserver configuration directory `~torrentbox/.vnc`' do
      expect(chef_run).to create_directory('/home/torrentbox/.vnc').with(
        owner: 'torrentbox',
        group: 'torrentbox',
        mode: '0755'
      )
    end

    it 'configures the vncserver session script `~torrentbox/.vnc/Xvnc-session`' do
      expect(chef_run).to create_template('/home/torrentbox/.vnc/Xvnc-session').with(
        source: 'tigervnc/Xvnc-session.erb',
        owner: 'torrentbox',
        group: 'torrentbox',
        mode: '0755',
        variables: {
          homepages: %w(
            http://localhost:9091
          ),
        }
      )
    end

    it 'restarts the `vncserver@:1` service on session script change' do
      expect(chef_run.template('/home/torrentbox/.vnc/Xvnc-session'))
        .to notify('service[vncserver@:1]')
        .to(:restart).delayed
    end

    it 'creates the `vncserver@:1` service' do
      expect(chef_run).to create_systemd_unit('vncserver@:1.service')
    end

    it 'enables the `vncserver@:1` service' do
      expect(chef_run).to enable_systemd_unit('vncserver@:1.service')
    end

    it 'stops the `vncserver@:1` service before systemd_unit change' do
      expect(chef_run.systemd_unit('vncserver@:1.service'))
        .to notify('service[vncserver@:1]')
        .to(:stop).before
    end

    it 'restart the `vncserver@:1` service after systemd_unit change' do
      expect(chef_run.systemd_unit('vncserver@:1.service'))
        .to notify('service[vncserver@:1]')
        .to(:restart).delayed
    end
  end
end
