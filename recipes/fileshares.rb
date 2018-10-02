#
# Cookbook:: torrentbox
# Recipe:: fileshares
#
# Copyright:: 2018, Nathan Dines, All Rights Reserved.

samba_server "#{cookbook_name} CIFS Server" do
  workgroup            'WORKSPACE'
  interfaces           node['network']['default_interface']
  bind_interfaces_only 'yes'
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
