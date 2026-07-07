# Docker stacks

Portainer-managed Docker Compose stacks for standalone Docker hosts.

## Layout

| Stack | Purpose | Endpoint |
|---|---|---|
| `core` | Docktail (Tailscale service proxy) | `docker-svc-0` |
| `monitoring` | Uptime-Kuma (Beszel later) | `docker-svc-0` |
| `networking` | Technitium DNS | mini PC |
| `docker-apps` | Misc apps (`whoami`) | `docker-svc-0` |

All app stacks attach to the `homelab_proxy` bridge network created by the `core` stack (Ansible ensures it exists before stacks deploy).

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

Stacks are deployed through Portainer GitOps from this repo. Ansible only bootstraps Docker, Tailscale, and Portainer.
