#
# Cookbook:: torrentbox
# Recipe:: default
#
# Copyright:: 2018, Nathan Dines, All Rights Reserved.

include_recipe "#{cookbook_name}::netconfig"
include_recipe "#{cookbook_name}::dnsmasq"
