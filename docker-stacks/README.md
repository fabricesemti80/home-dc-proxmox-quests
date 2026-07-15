# Docker stacks

Portainer-managed Docker stacks.

## Layout

Each compose file is a separate Portainer GitOps stack. Required variables live
in the repo root `.env` and are listed in `.env.example`.

| Area | Services | Endpoint |
|---|---|---|
| `apps/docker-compose.yml` | Beszel, Uptime Kuma, Whoami, Beszel agent | Swarm; apps pinned to `docker-svc-1`, agent global |
| `dashboard/docker-compose.yml` | Homepage | Swarm; pinned to `docker-svc-1` |
| `networking/docker-compose.yml` | Docktail, Technitium primary/secondary | Swarm; Docktail global, DNS pinned per host |
| `monitoring/docker-compose.yml` | Pulse | Swarm manager, constrained to `docker-svc-1` |

Services attach to `homelab_proxy`; Swarm stacks require that network to be a swarm-scope overlay network before deployment.

Beszel agent requires `BESZEL_AGENT_KEY`; without it the container exits with
`no key provided`. Docker agents listen on TCP `45876`, matching the host/port
configured in Beszel.

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
bootstraps Docker, Tailscale, Swarm, and Portainer.
