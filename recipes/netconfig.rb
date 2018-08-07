#
# Cookbook:: torrentbox
# Recipe:: netconfig
#
# Copyright:: 2018, Nathan Dines, All Rights Reserved.

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
