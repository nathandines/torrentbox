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

    %w(smbd nmbd).each do |this_service|
      it "creates the `#{this_service}` service directory" do
        expect(chef_run).to create_directory("/etc/systemd/system/#{this_service}.service.d").with(
          owner: 'root',
          group: 'root',
          mode:  '0755'
        )
      end

      it "deletes the `#{this_service}` service mount dependencies" do
        expect(chef_run).to delete_file("/etc/systemd/system/#{this_service}.service.d/mounts.conf")
      end

      it "enables the `#{this_service}` service" do
        expect(chef_run).to enable_service(this_service)
      end

      it "starts the `#{this_service}` service" do
        expect(chef_run).to start_service(this_service)
      end

      it "stops #{this_service} before changing the systemd unit file" do
        expect(chef_run.file("/etc/systemd/system/#{this_service}.service.d/mounts.conf"))
          .to notify("service[#{this_service}]")
          .to(:stop).before
      end

      it "reloads the #{this_service} unit after changing the systemd unit file" do
        expect(chef_run.file("/etc/systemd/system/#{this_service}.service.d/mounts.conf"))
          .to notify("systemd_unit[#{this_service}.service]")
          .to(:reload).immediately
      end

      it "restarts #{this_service} after changing the systemd unit file" do
        expect(chef_run.file("/etc/systemd/system/#{this_service}.service.d/mounts.conf"))
          .to notify("service[#{this_service}]")
          .to(:restart).delayed
      end

      it "shouldn't do anything with the `#{this_service}` systemd_unit" do
        expect(chef_run.systemd_unit("#{this_service}.service")).to do_nothing
      end
    end
  end
  context 'When file shares are configured, on Debian 9.4' do
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

    %w(smbd nmbd).each do |this_service|
      it "creates the `#{this_service}` service mount dependencies" do
        expect(chef_run).to create_file("/etc/systemd/system/#{this_service}.service.d/mounts.conf").with(
          content: <<-UNIT_DEFINITION.gsub(/^\s+/, ''),
            [Unit]
            RequiresMountsFor='/somemount1' '/some mount 2'
            UNIT_DEFINITION
          owner: 'root',
          group: 'root',
          mode:  '0644'
        )
      end

      it "stops #{this_service} before changing the systemd unit file" do
        expect(chef_run.file("/etc/systemd/system/#{this_service}.service.d/mounts.conf"))
          .to notify("service[#{this_service}]")
          .to(:stop).before
      end

      it "restarts #{this_service} after changing the systemd unit file" do
        expect(chef_run.file("/etc/systemd/system/#{this_service}.service.d/mounts.conf"))
          .to notify("service[#{this_service}]")
          .to(:restart).delayed
      end

      it "shouldn't do anything with the `#{this_service}` systemd_unit" do
        expect(chef_run.systemd_unit("#{this_service}.service")).to do_nothing
      end
    end
  end
end
