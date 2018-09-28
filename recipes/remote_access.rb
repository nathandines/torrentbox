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
  notifies :restart, 'service[vncserver@:1]', :delayed
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
    homepages: node['torrentbox']['remote_access']['homepages']
  )
  notifies :restart, 'service[vncserver@:1]', :delayed
end

systemd_unit 'vncserver@:1.service' do
  action %i(create enable)
  content <<-UNIT_DEFINITION.gsub(/^\s+/, '')
  [Unit]
  Description=Remote desktop service (VNC)
  After=syslog.target network.target

  [Service]
  Type=simple
  User=#{remote_access_user}
  PAMName=login
  PIDFile=/home/%u/.vnc/%H%i.pid
  Restart=always
  RestartSec=5

  # Clean any existing files in /tmp/.X11-unix environment
  ExecStartPre=/bin/sh -c '/usr/bin/vncserver -kill %i > /dev/null 2>&1 || true'
  ExecStart=/usr/bin/vncserver -geometry 1440x900 -fg -alwaysshared -localhost -SecurityTypes None %i
  ExecStop=/bin/sh -c '/usr/bin/vncserver -kill %i || true'

  [Install]
  WantedBy=multi-user.target
  UNIT_DEFINITION
  notifies :stop, 'service[vncserver@:1]', :before
  notifies :restart, 'service[vncserver@:1]', :delayed
end

service 'vncserver@:1' do
  action :nothing
end

directory "#{user_home}/.ssh" do
  owner remote_access_user
  group remote_access_user
  mode '0700'
end

file "#{user_home}/.ssh/authorized_keys" do
  owner remote_access_user
  group remote_access_user
  mode '0600'
  content node['torrentbox']['remote_access']['ssh_authorized_keys'].join("\n")
end
