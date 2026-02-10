#!/usr/bin/env bash
set -euo pipefail

NS="${NS:-default}"
TRAEFIK_NS="${TRAEFIK_NS:-traefik}"
TRAEFIK_SVC="${TRAEFIK_SVC:-traefik}"

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing required command: $1" >&2; exit 1; }; }
need kubectl

echo "== Nodes =="
kubectl get nodes -o wide

echo "\n== Retail app (ns=$NS) =="
kubectl get deploy,pod,svc,ingress -n "$NS" -o wide

echo "\n== Pending pods (if any) =="
kubectl get pods -n "$NS" --field-selector=status.phase=Pending -o wide || true

echo "\n== Traefik service =="
kubectl get svc -n "$TRAEFIK_NS" "$TRAEFIK_SVC" -o wide || true
