# Inspec test for recipe torrentbox::system_services

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe package('ntp') do
  it { should be_installed }
end

describe service('ntp') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end
