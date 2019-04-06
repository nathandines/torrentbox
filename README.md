# torrentbox

Repository which contains the code to deploy a VNC host for downloading torrents
over a secure VPN connection.

This was previously a private repository of mine, but I've decided to
open-source it in case somebody finds it useful. There should be more
documentation around the attributes and how to utilise the cookbook as a
resource in itself, but I don't have the time for it at the moment. A PR would
be welcome for this.

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
