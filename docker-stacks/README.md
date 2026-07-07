# Docker stacks

Portainer-managed Docker Compose stacks for standalone Docker hosts.

Each subfolder contains a `docker-stack.yml` and an `.env.example`. Secrets are sourced from 1Password and injected by Portainer environment variables.

## Endpoints

- `docker-svc-0` (Proxmox VM): Portainer server, general apps.
- `mini-pc-0` (bare metal): Portainer agent, Technitium DNS.

## Deployment

Stacks are deployed through the Portainer UI or GitOps. Ansible only bootstraps Portainer and the Docker hosts; it does not manage these stacks.
