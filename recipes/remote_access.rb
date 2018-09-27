#
# Cookbook:: torrentbox
# Recipe:: remote_access
#
# Copyright:: 2018, Nathan Dines, All Rights Reserved.

remote_access_user = node['torrentbox']['remote_access']['user']
user_home          = "/home/#{remote_access_user}"

%w(tigervnc-standalone-server openbox dbus-x11 fonts-dejavu firefox-esr).each do |package_name|
  package package_name
end

user remote_access_user do
  comment     'User for torrentbox remote access'
  manage_home true
  shell       '/usr/sbin/nologin'
  home        user_home
end

["#{user_home}/.config", "#{user_home}/.config/openbox"].each do |dest_directory|
  directory dest_directory do
    owner remote_access_user
    group remote_access_user
    mode  '0755'
  end
end

cookbook_file "#{user_home}/.config/openbox/rc.xml" do
  source 'openbox/rc.xml'
  owner  remote_access_user
  group  remote_access_user
  mode   '0644'
end

directory "#{user_home}/.vnc" do
  owner remote_access_user
  group remote_access_user
  mode  '0755'
end

template "#{user_home}/.vnc/Xvnc-session" do
  source 'tigervnc/Xvnc-session.erb'
  owner  remote_access_user
  group  remote_access_user
  mode   '0755'
  variables(
    remote_access_user: remote_access_user,
    homepages: node['torrentbox']['remote_access']['homepages']
  )
end
