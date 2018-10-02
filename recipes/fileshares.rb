#
# Cookbook:: torrentbox
# Recipe:: fileshares
#
# Copyright:: 2018, Nathan Dines, All Rights Reserved.

samba_server "#{cookbook_name} CIFS Server" do
  workgroup            'WORKGROUP'
  interfaces           node['network']['default_interface']
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
