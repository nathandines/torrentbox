# Inspec test for recipe torrentbox::openvpn

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe package('openvpn') do
  it { should_not be_installed }
end

describe file('/etc/openvpn/client.conf') do
  it { should_not exist }
end

describe file('/etc/openvpn/credentials') do
  it { should_not exist }
end

describe service('openvpn@client') do
  it { should_not be_installed }
  it { should_not be_enabled }
  it { should_not be_running }
end

describe command('ip route list table main exact 0.0.0.0/1') do
  its('stdout') { should eq '' }
end

describe command('ip route list table main exact 128.0.0.0/1') do
  its('stdout') { should eq '' }
end

(0..10).each do |number|
  describe file("/sys/class/net/tun#{number}") do
    it { should_not exist }
  end

  describe command("ip route list table main dev tun#{number}") do
    its('stderr') { should eq "Cannot find device \"tun#{number}\"\n" }
    its('exit_status') { should eq 1 }
  end
end

describe command('ping -qc 4 www.google.com') do
  its('exit_status') { should_not eq 0 }
end

describe command('host www.microsoft.com') do
  its('exit_status') { should_not eq 0 }
end

describe command('host pool.ntp.org') do
  its('exit_status') { should eq 0 }
end
