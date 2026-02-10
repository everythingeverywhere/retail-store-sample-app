#!/usr/bin/env bash
set -euo pipefail

NS="${NS:-default}"
DEPLOY="${DEPLOY:-ui}"
REPLICAS="${REPLICAS:-25}"

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing required command: $1" >&2; exit 1; }; }
need kubectl

echo "Scaling deployment/$DEPLOY in namespace $NS to replicas=$REPLICAS"
kubectl scale -n "$NS" deployment "$DEPLOY" --replicas="$REPLICAS"

echo "\nWatch pods (look for Pending if cluster is saturated):"
echo "  kubectl get pods -n $NS -w"

echo "\nCurrent snapshot:"
kubectl get deploy "$DEPLOY" -n "$NS" -o wide
kubectl get pods -n "$NS" -o wide | sed -n '1,40p'

echo "\nIf you want to wait for rollout:"
echo "  kubectl rollout status -n $NS deployment/$DEPLOY --timeout=10m"
