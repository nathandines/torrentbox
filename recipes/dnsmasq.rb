#
# Cookbook:: torrentbox
# Recipe:: dnsmasq
#
# Copyright:: 2018, Nathan Dines, All Rights Reserved.

vpn_provider = node['torrentbox']['openvpn']['provider']

package 'dnsmasq'
package 'resolvconf'

template '/etc/dnsmasq.conf' do
  action   :create
  source   'dnsmasq.conf.erb'
  owner    'root'
  group    'root'
  mode     '0644'
  notifies :restart, 'service[dnsmasq]', :immediately
  variables(
    local_dns:    node['torrentbox']['local_dns'],
    vpn_dns:      node['torrentbox']['vpn_dns'],
    vpn_domain:   node['torrentbox']['openvpn']['providers'][vpn_provider]['domain']
  )
end

service 'dnsmasq' do
  action %i(enable start)
end
