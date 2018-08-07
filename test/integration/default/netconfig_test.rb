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
