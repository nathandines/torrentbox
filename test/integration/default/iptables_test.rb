# Inspec test for recipe torrentbox::iptables

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

vpn_rules = [
  '-A VPN_INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT',
  '-A VPN_INPUT -p tcp -m tcp --dport 51234 -j ACCEPT',
  '-A VPN_INPUT -p udp -m udp --dport 51234 -j ACCEPT',
  '-A VPN_INPUT -p tcp -j REJECT --reject-with tcp-reset',
  '-A VPN_INPUT -p udp -j REJECT --reject-with icmp-port-unreachable',
  '-A VPN_INPUT -j REJECT --reject-with icmp-proto-unreachable',
]

vpn_rules.each do |rule|
  # Check rule on filesystem
  describe file('/etc/iptables.d/000_vpninput') do
    it { should be_file }
    its('content') { should match("^#{rule}$") }
  end

  # Check active rule
  describe iptables(table: 'filter', chain: 'VPN_INPUT') do
    it { should have_rule(rule) }
  end
end
