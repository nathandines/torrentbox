#
# Cookbook:: torrentbox
# Recipe:: fileshares
#
# Copyright:: 2018, Nathan Dines, All Rights Reserved.

samba_server "#{cookbook_name} CIFS Server" do
  workgroup            'WORKGROUP'
  interfaces           'eth* ath* wlan* wifi*'
  bind_interfaces_only 'yes'
  hosts_allow          '127.0.0.0/8 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16'
  load_printers        'no'
end

node['torrentbox']['fileshares'].each do |samba_share|
  share_name    = samba_share['name']
  share_path    = samba_share['path']

  samba_share share_name do
    path     share_path
    guest_ok 'yes'
  end
end

systemd_unit 'smbd.service' do
  action %i(create enable)
  content <<-UNIT_DEFINITION.gsub(/^\s+/, '')
  [Unit]
  Description=Samba SMB Daemon
  Documentation=man:smbd(8) man:samba(7) man:smb.conf(5)
  After=network.target nmbd.service winbind.service
  RequiresMountsFor='#{node['torrentbox']['fileshares'].map { |x| x['path'] }.join("' '")}'

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
  notifies :stop, 'service[smbd]', :before
  notifies :restart, 'service[smbd]', :delayed
end

systemd_unit 'nmbd.service' do
  action %i(create enable)
  content <<-UNIT_DEFINITION.gsub(/^\s+/, '')
  [Unit]
  Description=Samba NMB Daemon
  Documentation=man:nmbd(8) man:samba(7) man:smb.conf(5)
  After=network-online.target
  Wants=network-online.target
  RequiresMountsFor='#{node['torrentbox']['fileshares'].map { |x| x['path'] }.join("' '")}'

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
  notifies :stop, 'service[nmbd]', :before
  notifies :restart, 'service[nmbd]', :delayed
end

service 'smbd' do
  action :nothing
end

service 'nmbd' do
  action :nothing
end
