# Demo automation (SUSE Rancher for AWS / EKS)

These scripts make the retail-store-sample-app portion of the demo repeatable and fast.

## Quick start

From repo root:

```bash
chmod +x demo/*.sh

# 0) sanity check your kube context + Traefik
./demo/00-check.sh

# 1) deploy app
./demo/01-deploy.sh

# 2) expose via Traefik ingress (hostless by default)
./demo/02-expose-traefik.sh

# 3) get URL to open in browser
./demo/03-get-url.sh
```

Open the printed URL.

## Pressure moments (for the story)

### Scale UI replicas fast

```bash
REPLICAS=25 ./demo/04-pressure-scale-ui.sh
kubectl get pods -n default -w
```

### Generate load (optional)

```bash
URL="$(./demo/03-get-url.sh)" DURATION=90 CONCURRENCY=20 ./demo/05-pressure-generate-load.sh
```

## Variables you may need to override

- `NS` (default: `default`)
- `INGRESS_CLASS` (default: `traefik`)
- `TRAEFIK_NS` (default: `traefik`)
- `TRAEFIK_SVC` (default: `traefik`)
- `MANIFEST_URL` (default: upstream latest release kubernetes.yaml)

## Cleanup

```bash
./demo/99-cleanup.sh
```
