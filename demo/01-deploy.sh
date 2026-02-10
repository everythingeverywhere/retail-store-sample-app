#!/usr/bin/env bash
set -euo pipefail

NS="${NS:-default}"
# By default uses upstream release artifact (as README suggests)
MANIFEST_URL="${MANIFEST_URL:-https://github.com/aws-containers/retail-store-sample-app/releases/latest/download/kubernetes.yaml}"

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing required command: $1" >&2; exit 1; }; }
need kubectl

echo "Applying retail-store sample app manifest to namespace: $NS"
# upstream manifest is namespace-less; it will land in current namespace
kubectl apply -n "$NS" -f "$MANIFEST_URL"

echo "\nWaiting for Deployments to become Available (this can take a few minutes)..."
kubectl wait -n "$NS" --for=condition=available deployment --all --timeout=10m

echo "\nCurrent workloads:"
kubectl get deploy,pod,svc -n "$NS" -o wide
