:sparkles: network\_restarter - Restart network interface when network is unreachable :sparkles:
===============================================================================================

My Raspberry Pi sometimes loses connection and doesn't reconnect on its own. This script runs every minute and checks connectivity to a given address. After a defined amount of failures, it will restart the network interface.

You'll probably want to edit `network-restarter.service` and change the arguments of `network_restarter.sh`:

```
    -a <address>       - The address to ping. Your router's IP, for example, or 1.1.1.1
    -i <interface>     - The interface to restart. On a raspberry pi this is either
                         eth0 or wlan0 for ethernet and wifi respectively
    -c <count>         - Consider the network as down after this many failed pings.
                         By default, the service runs every minute, so restart after
                         this many minutes without network access.
    -f <counter file>  - By default, network_restarter will log the number of failures
                         to /tmp/network_restarter.cnt. Use this flag to set a different
                         path.
```
