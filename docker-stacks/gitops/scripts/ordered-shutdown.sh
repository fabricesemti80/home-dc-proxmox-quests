#!/usr/bin/env bash
set -euo pipefail

dry_run="${1:-true}"
require_ceph_healthy="${2:-true}"
phase="${3:-all}"

ssh_key="${HOMELAB_SSH_KEY:?HOMELAB_SSH_KEY is required}"
pbs_host="${HOMELAB_PBS_HOST:?HOMELAB_PBS_HOST is required}"
pve_hosts="${HOMELAB_PVE_HOSTS:?HOMELAB_PVE_HOSTS is required}"
pve_shutdown_order="${HOMELAB_PVE_SHUTDOWN_ORDER:-$pve_hosts}"
k8s_vms="${HOMELAB_K8S_VMS:?HOMELAB_K8S_VMS is required}"
service_guests="${HOMELAB_SERVICE_GUESTS:?HOMELAB_SERVICE_GUESTS is required}"

ssh_opts=(-i "$ssh_key" -o BatchMode=yes -o StrictHostKeyChecking=accept-new)

run() {
  echo "+ $*"
  if [ "$dry_run" != "true" ]; then
    "$@"
  fi
}

remote() {
  local host="$1"
  shift
  run ssh "${ssh_opts[@]}" "$host" "$@"
}

check_remote() {
  local host="$1"
  shift
  echo "+ ssh $host $*"
  ssh "${ssh_opts[@]}" "$host" "$@"
}

guest_cmd() {
  local guest="$1" action="$2"
  local id="${guest%@*}" host="${guest#*@}"
  local kind="qm"
  [ "$id" = "4016" ] && kind="pct"
  remote "$host" "$kind $action $id || true"
}

wait_guest_stopped() {
  local guest="$1"
  local id="${guest%@*}" host="${guest#*@}"
  local kind="qm"
  [ "$id" = "4016" ] && kind="pct"
  check_remote "$host" "for i in \$(seq 1 60); do $kind status $id | grep -q stopped && exit 0; sleep 5; done; $kind status $id; exit 1"
}

preflight() {
  echo "Checking for active PBS backup tasks"
  active_backups="$(check_remote "$pbs_host" "proxmox-backup-manager task list --all --output-format json" | tr '{' '\n' | grep '"worker_type":"backup"' | grep -v '"endtime"' || true)"
  if [ -n "$active_backups" ]; then
    echo "Active PBS backup tasks remain; refusing shutdown."
    echo "$active_backups"
    exit 1
  fi

  if [ "$require_ceph_healthy" = "true" ]; then
    echo "Checking Ceph health before shutdown"
    check_remote "$(set -- $pve_hosts; echo "$1")" "ceph -s | grep -q HEALTH_OK"
  fi
}

stop_k8s() {
  echo "Stopping Kubernetes control-plane VMs"
  for guest in $k8s_vms; do guest_cmd "$guest" shutdown; done
  if [ "$dry_run" != "true" ]; then
    for guest in $k8s_vms; do wait_guest_stopped "$guest"; done
  fi
}

stop_services() {
  echo "Stopping service guests"
  for guest in $service_guests; do guest_cmd "$guest" shutdown; done
  if [ "$dry_run" != "true" ]; then
    for guest in $service_guests; do wait_guest_stopped "$guest"; done
  fi
}

set_ceph_maintenance() {
  echo "Setting Ceph noout for maintenance"
  remote "$(set -- $pve_hosts; echo "$1")" "ceph osd set noout"
}

poweroff_hosts() {
  echo "Powering off Proxmox hosts"
  for host in $pve_shutdown_order; do
    remote "$host" "shutdown -h now"
  done
}

case "$phase" in
  all)
    preflight
    stop_k8s
    stop_services
    set_ceph_maintenance
    poweroff_hosts
    ;;
  preflight) preflight ;;
  stop_k8s) stop_k8s ;;
  stop_services) stop_services ;;
  set_ceph_maintenance) set_ceph_maintenance ;;
  poweroff_hosts) poweroff_hosts ;;
  *) echo "Unknown phase: $phase"; exit 2 ;;
esac
