# Inspec test for recipe torrentbox::netconfig

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe file('/etc/sysctl.d/40-ipv6.conf') do
  it { should be_file }
  its('owner') { should eq 'root' }
  its('group') { should eq 'root' }
  its('mode') { should cmp '0644' }
  its('content') { should eq 'net.ipv6.conf.all.disable_ipv6 = 1' }
end

describe command('sysctl -b net.ipv6.conf.all.disable_ipv6') do
  its('exit_status') { should cmp 0 }
  its('stdout') { should eq '1' }
end

describe file('/etc/network/interfaces') do
  it { should be_file }
  its('content') { should match(/^# Chef Template: v0\.1$/) }
  its('owner') { should eq 'root' }
  its('group') { should eq 'root' }
  its('mode') { should cmp '0644' }
end

describe file('/usr/local/sbin/asymmetric_routing.sh') do
  it { should be_file }
  its('owner') { should eq 'root' }
  its('group') { should eq 'root' }
  its('mode') { should cmp '0755' }
end

# Only the system-level dhclient daemon should be running, not the one for the
# eth0 interface
describe command('pgrep -f \'^/sbin/dhclient -4 -v -pf /run/dhclient.eth0.pid -lf /var/lib/dhcp/dhclient.eth0.leases -I -df /var/lib/dhcp/dhclient6.eth0.leases eth0$\'') do
  its('exit_status') { should cmp 1 }
end
