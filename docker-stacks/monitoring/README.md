# Monitoring stack

## Pulse

Pulse is pinned to the Swarm manager `docker-svc-1` and stores data on that host:

```text
/srv/docker/pulse/data
```

Use the LAN endpoint for host-side agent installs:

```sh
http://10.0.40.53:17655
```

The Tailscale service name `pulse.koala-dominant.ts.net` is for browser access
from tailnet clients and may not resolve on the service hosts.

Docker host agent install shape:

```sh
pulse_url='http://10.0.40.53:17655'
curl -fsSL "$pulse_url/install.sh" -o /tmp/pulse-install.sh
chmod +x /tmp/pulse-install.sh
printf %s "$PULSE_AGENT_TOKEN" > /tmp/pulse-token
sudo bash /tmp/pulse-install.sh --url "$pulse_url" \
  --token-file /tmp/pulse-token \
  --enable-docker \
  --non-interactive
rm -f /tmp/pulse-install.sh /tmp/pulse-token
```

Add `--disable-host` only when Pulse should monitor Docker containers without
also enrolling the underlying Docker host.

Docker host offline alerts are disabled in Pulse. The host agent already covers
host availability, while Docker container and service monitoring stays enabled.
