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
  its('shell') { should eq '/usr/sbin/nologin' }
end

%w(/home/torrentbox/.config /home/torrentbox/.config/openbox).each do |directory|
  describe file(directory) do
    it { should be_directory }
    its('owner') { should eq 'torrentbox' }
    its('group') { should eq 'torrentbox' }
    its('mode') { should cmp '0755' }
  end
end

describe file('/home/torrentbox/.config/openbox/rc.xml') do
  it { should be_file }
  its('owner') { should eq 'torrentbox' }
  its('group') { should eq 'torrentbox' }
  its('mode') { should cmp '0644' }
end

describe file('/home/torrentbox/.vnc') do
  it { should be_directory }
  its('owner') { should eq 'torrentbox' }
  its('group') { should eq 'torrentbox' }
  its('mode') { should cmp '0755' }
end

describe file('/home/torrentbox/.vnc/Xvnc-session') do
  it { should be_file }
  its('owner') { should eq 'torrentbox' }
  its('group') { should eq 'torrentbox' }
  its('mode') { should cmp '0755' }
end

# describe service('tigervnc') do
#   it { should be_installed }
#   it { should be_enabled }
#   it { should be_running }
# end

# describe processes('firefox-esr') do
#   it { should exist }
#   its('entries.length') { should eq 1 }
#   its('users') { should eq ['torrentbox'] }
# end
