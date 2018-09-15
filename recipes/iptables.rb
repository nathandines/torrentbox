#
# Cookbook:: torrentbox
# Recipe:: iptables
#
# Copyright:: 2018, Nathan Dines, All Rights Reserved.

include_recipe 'iptables::default'

iptables_rule '000_vpninput' do
  action :enable
  source 'iptables/000_vpninput.erb'
  variables(
    transmission_port: node['torrentbox']['transmission']['port']
  )
end

iptables_rule '100_ethernetoutput' do
  action :enable
  source 'iptables/100_ethernetoutput.erb'
  variables(
    local_dns: node['torrentbox']['local_dns'],
    destination_whitelist: node['torrentbox']['iptables']['destination_whitelist']
  )
end
