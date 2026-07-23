#!/usr/bin/env bash
set -euo pipefail

dry_run="${1:-true}"
wait_minutes="${2:-20}"
phase="${3:-all}"

ssh_key="${HOMELAB_SSH_KEY:?HOMELAB_SSH_KEY is required}"
pve_hosts="${HOMELAB_PVE_HOSTS:?HOMELAB_PVE_HOSTS is required}"
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

first_pve="$(set -- $pve_hosts; echo "$1")"
deadline=$((SECONDS + wait_minutes * 60))

wait_hosts() {
  echo "Waiting for Proxmox hosts to accept SSH"
  for host in $pve_hosts; do
    until ssh "${ssh_opts[@]}" "$host" true; do
      [ "$SECONDS" -lt "$deadline" ] || { echo "Timed out waiting for $host"; exit 1; }
      sleep 10
    done
  done
}

wait_ceph() {
  echo "Waiting for Ceph to become healthy"
  until check_remote "$first_pve" "ceph -s | grep -q HEALTH_OK"; do
    [ "$SECONDS" -lt "$deadline" ] || { echo "Timed out waiting for Ceph HEALTH_OK"; exit 1; }
    sleep 10
  done
}

clear_ceph_maintenance() {
  echo "Clearing Ceph noout"
  remote "$first_pve" "ceph osd unset noout || true"
}

start_services() {
  echo "Starting service guests"
  for guest in $service_guests; do guest_cmd "$guest" start; done
}

start_k8s() {
  echo "Starting Kubernetes control-plane VMs"
  for guest in $k8s_vms; do guest_cmd "$guest" start; done
}

case "$phase" in
  all)
    wait_hosts
    wait_ceph
    clear_ceph_maintenance
    start_services
    start_k8s
    ;;
  wait_hosts) wait_hosts ;;
  wait_ceph) wait_ceph ;;
  clear_ceph_maintenance) clear_ceph_maintenance ;;
  start_services) start_services ;;
  start_k8s) start_k8s ;;
  *) echo "Unknown phase: $phase"; exit 2 ;;
esac
