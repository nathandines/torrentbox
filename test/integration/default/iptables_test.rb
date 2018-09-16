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

describe command('iptables -t filter -S VPN_INPUT') do
  its('stdout') { should match "-N VPN_INPUT\n#{vpn_rules.join("\n")}\n" }
end

vpn_rules.each do |rule|
  # Check rule on filesystem
  describe file('/etc/iptables.d/000_vpninput') do
    it { should be_file }
    its('content') { should match("^#{rule}$") }
  end
end

# Ethernet Output

ethernet_rules = [
  '-A ETHOUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT',
  '-A ETHOUT -d 8.8.8.8/32 -p udp -m udp --dport 53 -j ACCEPT',
  '-A ETHOUT -d 8.8.4.4/32 -p udp -m udp --dport 53 -j ACCEPT',
  '-A ETHOUT -d 169.254.169.123/32 -j ACCEPT',
  '-A ETHOUT -d 169.254.168.0/24 -j ACCEPT',
  '-A ETHOUT -p udp -m udp --dport 1194 -j ACCEPT',
  '-A ETHOUT -p udp -m udp --dport 123 -j ACCEPT',
  '-A ETHOUT -p tcp -m tcp --sport 22 --tcp-flags ACK ACK -j ACCEPT',
  '-A ETHOUT -p tcp -m tcp -j REJECT --reject-with tcp-reset',
  '-A ETHOUT -p udp -m udp -j REJECT --reject-with icmp-port-unreachable',
  '-A ETHOUT -j REJECT --reject-with icmp-proto-unreachable',
]

describe command('iptables -t filter -S ETHOUT') do
  its('stdout') { should match "-N ETHOUT\n#{ethernet_rules.join("\n")}\n" }
end

ethernet_rules.each do |rule|
  # Check rule on filesystem
  describe file('/etc/iptables.d/100_ethernetoutput') do
    it { should be_file }
    its('content') { should match("^#{rule}$") }
  end
end

# Input

describe iptables do
  it { should have_rule('-P INPUT ACCEPT') }
end

input_rules = [
  '-A INPUT -i tun\+ -j VPN_INPUT',
]

describe command('iptables -t filter -S INPUT') do
  its('stdout') { should match "-P INPUT ACCEPT\n#{input_rules.join("\n").delete('\\')}\n" }
end

input_rules.each do |rule|
  # Check rule on filesystem
  describe file('/etc/iptables.d/900_input') do
    it { should be_file }
    its('content') { should match("^#{rule}$") }
  end
end

# Output

output_rules = [
  '-A OUTPUT -o lo -j ACCEPT',
  '-A OUTPUT -o tun\+ -j ACCEPT',
  '-A OUTPUT -j ETHOUT',
]

describe command('iptables -t filter -S OUTPUT') do
  its('stdout') { should match "-P OUTPUT DROP\n#{output_rules.join("\n").delete('\\')}\n" }
end

output_rules.each do |rule|
  # Check rule on filesystem
  describe file('/etc/iptables.d/900_output') do
    it { should be_file }
    its('content') { should match("^#{rule}$") }
  end
end
