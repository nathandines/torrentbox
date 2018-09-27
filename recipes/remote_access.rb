#
# Cookbook:: torrentbox
# Recipe:: remote_access
#
# Copyright:: 2018, Nathan Dines, All Rights Reserved.

%w(tigervnc-standalone-server openbox fonts-dejavu).each do |package_name|
  package package_name
end
