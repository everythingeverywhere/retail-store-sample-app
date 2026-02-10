#!/usr/bin/env bash
set -euo pipefail

NS="${NS:-default}"
INGRESS_CLASS="${INGRESS_CLASS:-traefik}"
TRAEFIK_NS="${TRAEFIK_NS:-traefik}"
TRAEFIK_SVC="${TRAEFIK_SVC:-traefik}"

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing required command: $1" >&2; exit 1; }; }
need kubectl

echo "Context: $(kubectl config current-context)"

echo "\n== Cluster reachability =="
kubectl version --short || true
kubectl get nodes -o wide

echo "\n== Namespace =="
kubectl get ns "$NS" >/dev/null

echo "\n== IngressClass =="
if kubectl get ingressclass "$INGRESS_CLASS" >/dev/null 2>&1; then
  kubectl get ingressclass "$INGRESS_CLASS" -o yaml | sed -n '1,40p'
else
  echo "WARNING: IngressClass '$INGRESS_CLASS' not found. Available:" >&2
  kubectl get ingressclass || true
fi

echo "\n== Traefik LoadBalancer service =="
if kubectl get svc -n "$TRAEFIK_NS" "$TRAEFIK_SVC" >/dev/null 2>&1; then
  kubectl get svc -n "$TRAEFIK_NS" "$TRAEFIK_SVC" -o wide
else
  echo "WARNING: Traefik service not found at $TRAEFIK_NS/$TRAEFIK_SVC" >&2
  echo "Existing services in $TRAEFIK_NS:" >&2
  kubectl get svc -n "$TRAEFIK_NS" || true
fi
