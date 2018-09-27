# Inspec test for recipe torrentbox::remote_access

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe package('tigervnc-standalone-server') do
  it { should be_installed }
end
