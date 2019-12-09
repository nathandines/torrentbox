#
# Cookbook:: torrentbox
# Recipe:: fileshares
#
# Copyright:: 2018, Nathan Dines, All Rights Reserved.

samba_server "#{cookbook_name} CIFS Server" do
  workgroup            'WORKGROUP'
  interfaces           'eth* ath* enp* wlan* wifi*'
  bind_interfaces_only 'yes'
  hosts_allow          '127.0.0.0/8 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16'
  load_printers        'no'
end

node['torrentbox']['fileshares'].each do |samba_share|
  share_name    = samba_share['name']
  share_path    = samba_share['path']

  directory share_path do
    action :create
    recursive true
    owner 'nobody'
    group 'nogroup'
    mode  '0777'
  end

  samba_share share_name do
    path     share_path
    guest_ok 'yes'
    create_directory false
    create_mask '0666'
    directory_mask '0777'
  end
end

%w(smbd nmbd).each do |this_service|
  directory "/etc/systemd/system/#{this_service}.service.d" do
    owner 'root'
    group 'root'
    mode  '0755'
  end

  if !node['torrentbox']['fileshares'].empty?
    file "/etc/systemd/system/#{this_service}.service.d/mounts.conf" do
      action :create
      owner 'root'
      group 'root'
      mode  '0644'
      content <<-UNIT_DEFINITION.gsub(/^\s+/, '')
      [Unit]
      RequiresMountsFor='#{node['torrentbox']['fileshares'].map { |x| x['path'] }.join("' '")}'
      UNIT_DEFINITION
      notifies :stop, "service[#{this_service}]", :before
      notifies :restart, "service[#{this_service}]", :delayed
    end
  else
    file "/etc/systemd/system/#{this_service}.service.d/mounts.conf" do
      action :delete
      notifies :stop, "service[#{this_service}]", :before
      notifies :reload, "systemd_unit[#{this_service}.service]", :immediately
      notifies :restart, "service[#{this_service}]", :delayed
    end
  end

  service this_service do
    action %i(enable start)
  end

  systemd_unit "#{this_service}.service" do
    action :nothing
  end
end
