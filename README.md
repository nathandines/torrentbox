# torrentbox

Repository which contains the code to deploy a VNC host for downloading torrents over a secure VPN connection

## Requirements

- Chef ~> 14.2
- Inspec ~> 2.2
- (Development) ChefDK ~> 3.2.30
  - Requires test-kitchen ~> 1.23.0 for lifecycle hooks

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
