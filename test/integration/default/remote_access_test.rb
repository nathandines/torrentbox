# Inspec test for recipe torrentbox::remote_access

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

%w(tigervnc-standalone-server openbox dbus-x11 fonts-dejavu firefox-esr).each do |package_name|
  describe package(package_name) do
    it { should be_installed }
  end
end

describe user('torrentbox') do
  it { should exist }
  its('home') { should eq '/home/torrentbox' }
  its('shell') { should eq '/bin/bash' }
end

%w(/home/torrentbox/.config /home/torrentbox/.config/openbox).each do |directory|
  describe file(directory) do
    it { should be_directory }
    its('owner') { should eq 'torrentbox' }
    its('group') { should eq 'torrentbox' }
    its('mode') { should cmp '00755' }
  end
end

describe file('/home/torrentbox/.config/openbox/rc.xml') do
  it { should be_file }
  its('owner') { should eq 'torrentbox' }
  its('group') { should eq 'torrentbox' }
  its('mode') { should cmp '00644' }
end

describe file('/home/torrentbox/.vnc') do
  it { should be_directory }
  its('owner') { should eq 'torrentbox' }
  its('group') { should eq 'torrentbox' }
  its('mode') { should cmp '00755' }
end

describe file('/home/torrentbox/.vnc/Xvnc-session') do
  it { should be_file }
  its('owner') { should eq 'torrentbox' }
  its('group') { should eq 'torrentbox' }
  its('mode') { should cmp '00755' }
end

describe service('vncserver@:1') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe port(5901) do
  it { should be_listening }
  its('processes') { should cmp 'Xtigervnc' }
  its('protocols') { should cmp 'tcp' }
  its('addresses') { should cmp '127.0.0.1' }
end

describe processes('firefox-esr') do
  it { should exist }
  # its('entries.length') { should eq 1 }
  # its('users') { should eq ['torrentbox'] }
end

describe file('/home/torrentbox/.ssh') do
  it { should be_directory }
  its('owner') { should eq 'torrentbox' }
  its('group') { should eq 'torrentbox' }
  its('mode') { should cmp '00700' }
end

describe file('/home/torrentbox/.ssh/authorized_keys') do
  it { should be_file }
  its('owner') { should eq 'torrentbox' }
  its('group') { should eq 'torrentbox' }
  its('mode') { should cmp '00600' }
end
