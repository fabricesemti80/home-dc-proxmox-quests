# Monitoring stack

## Uptime Kuma

Uptime Kuma is pinned to `PULSE_HOSTNAME`, currently managed by Ansible as
`sentinel-0`.

It uses the existing named Docker volume so the stack move does not change the
container data path:

```text
docker_apps_uptime_kuma_data -> /app/data
```

Because Docker named volumes are node-local, moving Uptime Kuma from
`sentinel-1` to `sentinel-0` requires copying that named volume data once.

## Pulse

Pulse is pinned to `PULSE_HOSTNAME`, currently managed by Ansible as `sentinel-0`.
It stores data on that host:

```text
/srv/docker/pulse/data
```

Use the LAN endpoint for host-side agent installs:

```sh
http://10.0.40.55:17655
```

The Tailscale service name `pulse.koala-dominant.ts.net` is for browser access
from tailnet clients and may not resolve on the service hosts.

Docker host agent install shape:

```sh
pulse_url='http://10.0.40.55:17655'
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

## Migrating Pulse data

Pulse data is a bind mount, not a named Docker volume:

```text
/srv/docker/pulse/data
```

Minimal interruption migration from `sentinel-1` to `sentinel-0`:

1. Pre-copy while Pulse is still running:

```sh
rsync -aHAX --numeric-ids --info=progress2 sentinel-1:/srv/docker/pulse/data/ sentinel-0:/srv/docker/pulse/data/
```

2. Stop the old Pulse task:

```sh
docker service scale homelab-monitoring_pulse=0
```

3. Final copy:

```sh
rsync -aHAX --numeric-ids --delete --info=progress2 sentinel-1:/srv/docker/pulse/data/ sentinel-0:/srv/docker/pulse/data/
```

4. Redeploy `homelab-monitoring` from Komodo, or run `task ansible:apply` and let the resource sync deploy it.

5. Verify:

```sh
curl -kI https://pulse.koala-dominant.ts.net
```
