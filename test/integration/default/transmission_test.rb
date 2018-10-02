# Inspec test for recipe torrentbox::transmission

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe package('transmission-daemon') do
  it { should be_installed }
end

describe file('/etc/transmission-daemon/settings.json') do
  it { should be_file }
  its('owner') { should eq 'debian-transmission' }
  its('group') { should eq 'debian-transmission' }
  its('mode') { should cmp '00600' }
end

describe file('/var/lib/transmission-daemon/downloads') do
  it { should be_directory }
  its('owner') { should eq 'debian-transmission' }
  its('group') { should eq 'debian-transmission' }
  its('mode') { should cmp '02777' }
end

describe file('/var/lib/transmission-daemon/torrents') do
  it { should be_directory }
  its('owner') { should eq 'debian-transmission' }
  its('group') { should eq 'debian-transmission' }
  its('mode') { should cmp '02777' }
end

describe service('transmission-daemon') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe port(9091) do
  it { should be_listening }
  its('addresses') { should cmp '127.0.0.1' }
end

describe port(51234) do
  it { should be_listening }
end

describe command('systemctl show transmission-daemon') do
  its('stdout') { should match(%r{RequiresMountsFor=/var/lib/transmission-daemon}) }
end
