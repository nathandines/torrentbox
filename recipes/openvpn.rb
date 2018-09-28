#
# Cookbook:: torrentbox
# Recipe:: openvpn
#
# Copyright:: 2018, Nathan Dines, All Rights Reserved.

vpn_provider = node['torrentbox']['openvpn']['provider']

package 'openvpn'

template '/etc/openvpn/client.conf' do
  action   :create
  source   "openvpn/#{vpn_provider}.conf.erb"
  owner    'root'
  group    'root'
  mode     '0644'
  notifies :restart, 'service[openvpn@client]', :delayed
  variables(
    server: node['torrentbox']['openvpn']['providers'][vpn_provider]['server']
  )
end

file '/etc/openvpn/credentials' do
  action    :create
  content   [node['torrentbox']['openvpn']['username'], node['torrentbox']['openvpn']['password']].join("\n")
  owner     'root'
  group     'root'
  mode      '0600'
  sensitive true
  notifies  :restart, 'service[openvpn@client]', :delayed
end

service 'openvpn@client' do
  action %i(enable start)
end
