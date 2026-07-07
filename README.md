# home-dc-proxmox-quests

Standalone Proxmox guest lifecycle for the home DC.

## Ownership

This repo owns long-lived VMs and LXCs that are not part of the Proxmox host
platform and not part of the Talos/Kubernetes cluster.

- `home-dc-proxmox`: Proxmox hosts, Ceph, storage, templates, pools, API tokens, backup policy.
- `home-dc-kubernetes`: Talos VMs and Kubernetes lifecycle.
- `home-dc-proxmox-quests`: standalone utility guests such as Technitium DNS.

## Tooling

Use Terraform for guest lifecycle. It gives a real plan, state, drift detection,
and destroy semantics for VM/LXC resources.

Terraform is run through the official Linux container in `Taskfile.yaml` because
the Darwin `bpg/proxmox` provider can plan locally but fails during apply on
this workstation.

Use Ansible only after provisioning, for inside-guest configuration that cannot
be expressed cleanly as Proxmox resources.

Terragrunt is intentionally skipped for now. Add it only if this grows into
multiple repeated environments.

## Workflow

```sh
task tf:init
task tf:plan
task tf:apply
task ansible:apply
```

Terraform lives in `terraform/` and Ansible lives in `ansible/`.

Create `.env` from `.env.example`. For now this repo uses Proxmox ticket auth
because privileged LXC feature flags are rejected through API tokens.

## Ansible

`proxmox_debian_guests` receives the `debian_base` role. Service-specific
groups, such as `proxmox_backup_servers`, add narrow roles on top.

`docker_standalone_hosts` receives Docker, host-level Tailscale, and Portainer
bootstrap. Portainer manages application stacks from `docker-stacks/`.

## Guest Modules

Use `modules/lxc_guest` for containers and `modules/vm_guest` for VMs. Leave
`vlan_id` unset for the host native VLAN; set it only for tagged VLANs.

LXC NFS mounts require privileged containers plus `mount_types = ["nfs"]`.
Changing an existing unprivileged LXC to privileged forces replacement, so PBS
should move to a VM if it needs to own backup storage directly.
