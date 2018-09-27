# Inspec test for recipe torrentbox::remote_access

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

%w(tigervnc-standalone-server openbox fonts-dejavu).each do |package_name|
  describe package(package_name) do
    it { should be_installed }
  end
end
