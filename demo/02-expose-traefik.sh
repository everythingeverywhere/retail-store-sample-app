#!/usr/bin/env bash
set -euo pipefail

NS="${NS:-default}"
INGRESS_FILE="${INGRESS_FILE:-hosteless-ingrss.yaml}"

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing required command: $1" >&2; exit 1; }; }
need kubectl

echo "Patching ui service to ClusterIP (so ingress owns external exposure)..."
kubectl patch -n "$NS" svc ui -p '{"spec":{"type":"ClusterIP"}}'

echo "\nApplying Traefik ingress: $INGRESS_FILE"
kubectl apply -n "$NS" -f "$INGRESS_FILE"

echo "\nIngress + service status:"
kubectl get ingress -n "$NS" -o wide
kubectl get svc ui -n "$NS" -o wide
