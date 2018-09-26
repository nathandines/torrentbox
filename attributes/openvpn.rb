default['torrentbox']['openvpn'].tap do |openvpn|
  openvpn['username'] = 'username_undefined'
  openvpn['password'] = 'password_undefined'

  openvpn['provider'] = 'pia'

  openvpn['providers']['pia'].tap do |pia|
    pia['domain'] = 'privateinternetaccess.com'
    pia['server'] = "swiss.#{pia['domain']}"
  end
end
