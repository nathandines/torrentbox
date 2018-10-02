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
      runner.node.normal['torrentbox']['fileshares'] = [
        {
          'name': 'Some Share One',
          'path': '/somemount1',
        },
        {
          'name': 'Some Share Two',
          'path': '/some mount 2',
        },
      ]
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'installs `samba`' do
      expect(chef_run).to install_package('samba')
    end

    it 'creates the `smbd` service' do
      expect(chef_run).to create_systemd_unit('smbd.service').with(
        content: <<-UNIT_DEFINITION.gsub(/^\s+/, '')
          [Unit]
          Description=Samba SMB Daemon
          Documentation=man:smbd(8) man:samba(7) man:smb.conf(5)
          After=network.target nmbd.service winbind.service
          RequiresMountsFor='/somemount1' '/some mount 2'

          [Service]
          Type=notify
          NotifyAccess=all
          PIDFile=/var/run/samba/smbd.pid
          LimitNOFILE=16384
          EnvironmentFile=-/etc/default/samba
          ExecStart=/usr/sbin/smbd $SMBDOPTIONS
          ExecReload=/bin/kill -HUP $MAINPID
          LimitCORE=infinity

          [Install]
          WantedBy=multi-user.target
          UNIT_DEFINITION
      )
    end

    it 'creates the `nmbd` service' do
      expect(chef_run).to create_systemd_unit('nmbd.service').with(
        content: <<-UNIT_DEFINITION.gsub(/^\s+/, '')
          [Unit]
          Description=Samba NMB Daemon
          Documentation=man:nmbd(8) man:samba(7) man:smb.conf(5)
          After=network-online.target
          Wants=network-online.target
          RequiresMountsFor='/somemount1' '/some mount 2'

          [Service]
          Type=notify
          NotifyAccess=all
          PIDFile=/var/run/samba/nmbd.pid
          EnvironmentFile=-/etc/default/samba
          ExecStart=/usr/sbin/nmbd $NMBDOPTIONS
          ExecReload=/bin/kill -HUP $MAINPID
          LimitCORE=infinity

          [Install]
          WantedBy=multi-user.target
          UNIT_DEFINITION
      )
    end

    %w(smbd nmbd).each do |this_service|
      it "enables the `#{this_service}` service" do
        expect(chef_run).to enable_systemd_unit("#{this_service}.service")
      end

      it "must do nothing for the service `#{this_service}` by default" do
        expect(chef_run.service(this_service)).to do_nothing
      end

      it "stops #{this_service} before changing the systemd unit file" do
        expect(chef_run.systemd_unit("#{this_service}.service"))
          .to notify("service[#{this_service}]")
          .to(:stop).before
      end

      it "restarts #{this_service} after changing the systemd unit file" do
        expect(chef_run.systemd_unit("#{this_service}.service"))
          .to notify("service[#{this_service}]")
          .to(:restart).delayed
      end
    end
  end
end
