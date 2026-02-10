#!/usr/bin/env bash
set -euo pipefail

NS="${NS:-default}"
URL="${URL:-}"
DURATION="${DURATION:-90}"
CONCURRENCY="${CONCURRENCY:-20}"

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing required command: $1" >&2; exit 1; }; }
need kubectl

if [[ -z "$URL" ]]; then
  echo "URL is required. Example:" >&2
  echo "  URL=\"$(./demo/03-get-url.sh)\" ./demo/05-pressure-generate-load.sh" >&2
  exit 1
fi

# We use a Job so you can show it in Rancher UI and it cleans itself up.
JOB_NAME="retail-load-$(date +%H%M%S)"

cat <<EOF | kubectl apply -n "$NS" -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: ${JOB_NAME}
  labels:
    app: retail-load
spec:
  ttlSecondsAfterFinished: 120
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: curl-loop
        image: curlimages/curl:8.5.0
        env:
        - name: URL
          value: "${URL}"
        - name: DURATION
          value: "${DURATION}"
        - name: CONCURRENCY
          value: "${CONCURRENCY}"
        command: ["sh","-c"]
        # Very simple concurrent curl loop. (No extra tools needed.)
        args:
        - |
          end=$((SECONDS + DURATION))
          echo "Generating load for ${DURATION}s against ${URL} with concurrency=${CONCURRENCY}"
          i=0
          while [ $SECONDS -lt $end ]; do
            i=$((i+1))
            for n in $(seq 1 $CONCURRENCY); do
              (curl -fsS -m 2 "${URL}" >/dev/null 2>&1 || true) &
            done
            wait
            if [ $((i % 5)) -eq 0 ]; then echo "tick ${i}"; fi
          done
          echo "done"
EOF

echo "Job created: $JOB_NAME"
echo "Follow logs: kubectl logs -n $NS job/$JOB_NAME -f"
