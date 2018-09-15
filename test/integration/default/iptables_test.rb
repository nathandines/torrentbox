# Inspec test for recipe torrentbox::iptables

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

# VPN Input

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

# Ethernet Output

ethernet_rules = [
  '-A ETHOUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT',
  '-A ETHOUT -d 1.1.1.1/32 -p udp -m udp --dport 53 -j ACCEPT',
  '-A ETHOUT -d 1.0.0.1/32 -p udp -m udp --dport 53 -j ACCEPT',
  '-A ETHOUT -d 169.254.169.123/32 -j ACCEPT',
  '-A ETHOUT -d 169.254.168.0/24 -j ACCEPT',
  '-A ETHOUT -p udp -m udp --dport 1194 -j ACCEPT',
  '-A ETHOUT -p udp -m udp --dport 123 -j ACCEPT',
  '-A ETHOUT -p tcp -m tcp --sport 22 --tcp-flags ACK ACK -j ACCEPT',
  '-A ETHOUT -p tcp -m tcp -j REJECT --reject-with tcp-reset',
  '-A ETHOUT -p udp -m udp -j REJECT --reject-with icmp-port-unreachable',
  '-A ETHOUT -j REJECT --reject-with icmp-proto-unreachable',
]

ethernet_rules.each do |rule|
  # Check rule on filesystem
  describe file('/etc/iptables.d/100_ethernetoutput') do
    it { should be_file }
    its('content') { should match("^#{rule}$") }
  end

  # Check active rule
  describe iptables(table: 'filter', chain: 'ETHOUT') do
    it { should have_rule(rule) }
  end
end

# Input

describe iptables do
  it { should have_rule('-P INPUT ACCEPT') }
end

output_rules = [
  '-A INPUT -i tun\+ -j VPN_INPUT',
]

output_rules.each do |rule|
  # Check rule on filesystem
  describe file('/etc/iptables.d/900_input') do
    it { should be_file }
    its('content') { should match("^#{rule}$") }
  end

  # Check active rule
  describe iptables(table: 'filter', chain: 'INPUT') do
    it { should have_rule(rule.delete('\\')) }
  end
end

# Output

describe iptables do
  it { should have_rule('-P OUTPUT DROP') }
end

output_rules = [
  '-A OUTPUT -o lo -j ACCEPT',
  '-A OUTPUT -o tun\+ -j ACCEPT',
  '-A OUTPUT -j ETHOUT',
]

output_rules.each do |rule|
  # Check rule on filesystem
  describe file('/etc/iptables.d/900_output') do
    it { should be_file }
    its('content') { should match("^#{rule}$") }
  end

  # Check active rule
  describe iptables(table: 'filter', chain: 'OUTPUT') do
    it { should have_rule(rule.delete('\\')) }
  end
end
