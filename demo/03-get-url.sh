#!/usr/bin/env bash
set -euo pipefail

TRAEFIK_NS="${TRAEFIK_NS:-traefik}"
TRAEFIK_SVC="${TRAEFIK_SVC:-traefik}"
SCHEME="${SCHEME:-http}"

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing required command: $1" >&2; exit 1; }; }
need kubectl

host="$(kubectl get svc -n "$TRAEFIK_NS" "$TRAEFIK_SVC" -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || true)"
if [[ -z "$host" ]]; then
  # some environments provide an IP
  host="$(kubectl get svc -n "$TRAEFIK_NS" "$TRAEFIK_SVC" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)"
fi

if [[ -z "$host" ]]; then
  echo "Traefik LoadBalancer address not ready yet. Current service:" >&2
  kubectl get svc -n "$TRAEFIK_NS" "$TRAEFIK_SVC" -o wide >&2
  exit 1
fi

echo "${SCHEME}://${host}/"
