#!/usr/bin/env bash
set -euo pipefail

NS="${NS:-retail}"

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing required command: $1" >&2; exit 1; }; }
need kubectl

echo "About to DELETE namespace '$NS' (this removes ALL resources in that namespace)."
read -r -p "Type the namespace name to confirm (${NS}): " confirm
if [[ "$confirm" != "$NS" ]]; then
  echo "Aborted."
  exit 1
fi

kubectl delete namespace "$NS" --wait=true

echo "Namespace '$NS' deleted."
