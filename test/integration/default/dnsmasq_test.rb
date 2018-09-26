# Inspec test for recipe torrentbox::dnsmasq

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe package('dnsmasq') do
  it { should be_installed }
end

describe file('/etc/dnsmasq.conf') do
  it { should be_file }
  its('content') { should match(/^# Chef Template: v0\.1$/) }
  its('content') { should match('^server=/pool\.ntp\.org/privateinternetaccess\.com/8\.8\.8\.8$') }
  its('content') { should match('^server=/pool\.ntp\.org/privateinternetaccess\.com/8\.8\.4\.4$') }
  its('content') { should match('^server=1\.1\.1\.1$') }
  its('content') { should match('^server=1\.0\.0\.1$') }
  its('owner') { should eq 'root' }
  its('group') { should eq 'root' }
  its('mode') { should cmp '0644' }
end

describe service('dnsmasq') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe port(53) do
  it { should be_listening }
  its('addresses') { should cmp '127.0.0.1' }
end

describe file('/etc/resolv.conf') do
  it { should be_file }
  its('content') { should eq 'nameserver 127.0.0.1' }
end
