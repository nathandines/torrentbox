#
# Cookbook:: torrentbox
# Recipe:: default
#
# Copyright:: 2018, Nathan Dines, All Rights Reserved.

include_recipe "#{cookbook_name}::dnsmasq"
include_recipe "#{cookbook_name}::netconfig"
include_recipe "#{cookbook_name}::remote_access"
include_recipe "#{cookbook_name}::system_services"
include_recipe "#{cookbook_name}::transmission"
include_recipe "#{cookbook_name}::fileshares"
include_recipe "#{cookbook_name}::openvpn" if node['torrentbox']['vpn_enabled']
include_recipe "#{cookbook_name}::iptables"
