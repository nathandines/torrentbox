#
# Cookbook:: torrentbox
# Recipe:: transmission
#
# Copyright:: 2018, Nathan Dines, All Rights Reserved.

storage_parent = node['torrentbox']['transmission']['storage_parent']
download_path = "#{storage_parent}/downloads"
torrent_watchdir_path = "#{storage_parent}/torrents"

package 'transmission-daemon'

systemd_unit 'transmission-daemon.service' do
  action :nothing
end

service 'transmission-daemon' do
  supports restart: true, reload: true
  action %i(enable start)
end

[download_path, torrent_watchdir_path].each do |this_directory|
  directory this_directory do
    owner 'debian-transmission'
    group 'debian-transmission'
    mode  '2777'
  end
end

template '/etc/transmission-daemon/settings.json' do
  source 'transmission/settings.json.erb'
  owner  'debian-transmission'
  group  'debian-transmission'
  mode   '0600'
  variables(
    transmission_port: node['torrentbox']['transmission']['port'],
    download_path: download_path,
    torrent_watchdir_path: torrent_watchdir_path
  )
  notifies :reload, 'service[transmission-daemon]', :immediately
end

directory '/etc/systemd/system/transmission-daemon.service.d' do
  owner 'root'
  group 'root'
  mode  '0755'
end

file '/etc/systemd/system/transmission-daemon.service.d/mounts.conf' do
  owner 'root'
  group 'root'
  mode  '0644'
  content <<-UNIT_DEFINITION.gsub(/^\s+/, '')
  [Unit]
  RequiresMountsFor='#{storage_parent}'
  UNIT_DEFINITION
  notifies :stop, 'service[transmission-daemon]', :before
  notifies :reload, 'systemd_unit[transmission-daemon.service]', :immediately
  notifies :restart, 'service[transmission-daemon]', :delayed
end
