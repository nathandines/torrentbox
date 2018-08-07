# torrentbox

Repository which contains the code to deploy a VNC host for downloading torrents over a secure VPN connection

## Requirements

- Chef ~> 14.3
- Inspec ~> 2.2
- (Development) ChefDK ~> 3.1.0

## Development

Tests are orchestrated through `rake`.

### Style Tests

```sh
chef exec rake style
```

### Integration Tests

```sh
chef exec rake integration
```
