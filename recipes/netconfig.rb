#
# Cookbook:: torrentbox
# Recipe:: netconfig
#
# Copyright:: 2018, Nathan Dines, All Rights Reserved.

default_ifname    = node['network']['default_interface']
default_ifaddress = node['ipaddress']
default_ifmask    = node['network']['interfaces'][default_ifname]['addresses'][default_ifaddress]['netmask']
default_ifgw      = node['network']['default_gateway']

file '/etc/sysctl.d/40-ipv6.conf' do
  action   :create
  owner    'root'
  group    'root'
  mode     '0644'
  content  'net.ipv6.conf.all.disable_ipv6 = 1'
  notifies :run, 'execute[sysctl_refresh]', :delayed
end

execute 'sysctl_refresh' do
  action  :nothing
  command 'sysctl --system'
end

template '/etc/network/interfaces' do
  action :create
  owner  'root'
  group  'root'
  mode   '0644'
  source 'networking/interfaces.erb'
  variables(
    ifname: default_ifname,
    ifaddress: default_ifaddress,
    ifmask: default_ifmask,
    ifgw: default_ifgw
  )
  notifies :run, 'execute[reload_network]', :delayed
end

execute 'reload_network' do # ~FC004
  action :nothing
  command "systemctl stop ifup@#{default_ifname}; ifdown #{default_ifname}; ifup #{default_ifname}"
end
