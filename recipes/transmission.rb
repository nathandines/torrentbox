#
# Cookbook:: torrentbox
# Recipe:: transmission
#
# Copyright:: 2018, Nathan Dines, All Rights Reserved.

storage_parent = node['torrentbox']['transmission']['storage_parent']
download_path = "#{storage_parent}/downloads"
torrent_watchdir_path = "#{storage_parent}/torrents"

package 'transmission-daemon'

service 'transmission-daemon' do
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
  mode   '0400'
  variables(
    transmission_port: node['torrentbox']['transmission']['port'],
    download_path: download_path,
    torrent_watchdir_path: torrent_watchdir_path
  )
  notifies :reload, 'service[transmission-daemon]', :delayed
end
