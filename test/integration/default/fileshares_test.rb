# Inspec test for recipe torrentbox::fileshares

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe package('samba') do
  it { should be_installed }
end

describe service('smbd') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe service('nmbd') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe port(445) do
  it { should be_listening }
end

describe port(139) do
  it { should be_listening }
end

describe file('/etc/samba/smb.conf') do
  it { should exist }
end

describe file('/etc/samba/smb.conf') do
  its('content') { should match(/workgroup = WORKGROUP/) }
  its('content') { should match(/security = user/) }
  its('content') { should match(%r{hosts allow = 127\.0\.0\.0/8 10\.0\.0\.0/8 172\.16\.0\.0/12 192\.168\.0\.0/16}) }
  its('content') { should match(/map to guest = Bad User/) }
  its('content') { should match(/interfaces = eth0/) }
  its('content') { should match(/load printers = no/) }
  its('content') { should match(/bind interfaces only = yes/) }
end
