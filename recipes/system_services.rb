#
# Cookbook:: torrentbox
# Recipe:: system_services
#
# Copyright:: 2018, Nathan Dines, All Rights Reserved.

package 'ntp'

service 'ntp' do
  action %i(enable start)
end
