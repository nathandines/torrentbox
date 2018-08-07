#
# Cookbook:: torrentbox
# Recipe:: dnsmasq
#
# Copyright:: 2018, Nathan Dines, All Rights Reserved.

package 'dnsmasq'

template '/etc/dnsmasq.conf' do
  source   'dnsmasq.conf.erb'
  owner    'root'
  group    'root'
  mode     '0644'
  notifies :restart, 'service[dnsmasq]', :delayed
  variables(
    local_dns:    node['torrentbox']['local_dns'],
    vpn_dns:      node['torrentbox']['vpn_dns'],
    vpn_hostname: node['torrentbox']['vpn_hostname']
  )
end

service 'dnsmasq' do
  action %i(enable start)
end
