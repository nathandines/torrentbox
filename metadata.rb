name 'torrentbox'
maintainer 'Nathan Dines'
maintainer_email 'nath@ndin.es'
license 'MIT'
description 'Installs/Configures torrentbox'
long_description 'Installs/Configures torrentbox'
version '0.1.0'
chef_version '~> 14.2' if respond_to?(:chef_version)

supports 'debian', '~> 9.4'

depends 'iptables', '~> 4.4.1'
depends 'samba', '~> 1.2.0'

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
issues_url 'https://github.com/nathandines/torrentbox/issues'

# The `source_url` points to the development repository for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
source_url 'https://github.com/nathandines/torrentbox'
