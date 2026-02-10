#!/usr/bin/env bash
set -euo pipefail

NS="${NS:-default}"
MANIFEST_URL="${MANIFEST_URL:-https://github.com/aws-containers/retail-store-sample-app/releases/latest/download/kubernetes.yaml}"

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing required command: $1" >&2; exit 1; }; }
need kubectl

echo "This will delete the retail app resources from namespace '$NS' and remove demo ingresses."
read -r -p "Continue? (yes/no) " ans
if [[ "$ans" != "yes" ]]; then
  echo "Aborted."
  exit 0
fi

# Delete demo ingresses (ignore if missing)
kubectl delete -n "$NS" ingress retail-ui-anyhost retail-ui --ignore-not-found

# Delete upstream manifest objects
kubectl delete -n "$NS" -f "$MANIFEST_URL" --ignore-not-found

# Best-effort cleanup any leftover load jobs
kubectl delete -n "$NS" job -l app=retail-load --ignore-not-found || true

echo "Cleanup submitted. Current resources:"
kubectl get all -n "$NS" | sed -n '1,80p'
