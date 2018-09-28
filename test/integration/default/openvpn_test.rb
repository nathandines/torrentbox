# Inspec test for recipe torrentbox::openvpn

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe package('openvpn') do
  it { should be_installed }
end

describe file('/etc/openvpn/client.conf') do
  it { should be_file }
  its('owner') { should eq 'root' }
  its('group') { should eq 'root' }
  its('mode') { should cmp '00644' }
end

describe file('/etc/openvpn/credentials') do
  it { should be_file }
  its('owner') { should eq 'root' }
  its('group') { should eq 'root' }
  its('mode') { should cmp '00600' }
end

describe service('openvpn@client') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe command('ip route list table main exact 0.0.0.0/1') do
  its('stdout') { should match %r{^0\.0\.0\.0\/1 via (?:\d{1,3}\.){3}\d{1,3} dev tun0 \n$} }
end

describe command('ip route list table main exact 128.0.0.0/1') do
  its('stdout') { should match %r{^128\.0\.0\.0/1 via (?:\d{1,3}\.){3}\d{1,3} dev tun0 \n$} }
end

describe file('/sys/class/net/tun0') do
  it { should be_directory }
end

(1..10).each do |number|
  describe file("/sys/class/net/tun#{number}") do
    it { should_not exist }
  end

  describe command("ip route list table main dev tun#{number}") do
    its('stderr') { should eq "Cannot find device \"tun#{number}\"\n" }
    its('exit_status') { should eq 1 }
  end
end

describe command('ping -qc 4 www.google.com') do
  its('exit_status') { should eq 0 }
end

describe command('host www.microsoft.com') do
  its('exit_status') { should eq 0 }
end
