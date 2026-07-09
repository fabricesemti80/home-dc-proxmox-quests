# Docker stacks

Portainer-managed Docker Compose stacks for standalone Docker hosts.

## Layout

Each compose file is a separate Portainer GitOps stack. Required variables live
in the repo root `.env` and are listed in `.env.example`.

| Area | Services | Endpoint |
|---|---|---|
| `docker-compose.yml` | Docktail, Whoami, Uptime Kuma, Technitium | Docker hosts |
| `apps/docker-compose.yml` | Vaultwarden, Beszel, Beszel agent | `docker-svc-0` |
| `dashboard/docker-compose.yml` | Homepage | `docker-svc-0` |
| `networking/docker-compose.yml` | Docktail, Technitium | networking hosts |

All services attach to the `homelab_proxy` bridge network (Ansible ensures it exists before the stack deploys).

Beszel agent requires `BESZEL_AGENT_KEY`; without it the container exits with
`no key provided`.

## HTTPS

App labels expose services via Docktail as native Tailscale Services on port 443 with automatic Tailscale HTTPS certificates, e.g.:

```yaml
labels:
  docktail.service.enable: "true"
  docktail.service.name: whoami
  docktail.service.port: "80"
  docktail.service.service-port: "443"
  docktail.service.protocol: http
```

## Deployment

Portainer GitOps pulls these compose files from this repo. Ansible only
bootstraps Docker, Tailscale, and Portainer.
