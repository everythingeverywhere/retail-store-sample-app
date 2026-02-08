# Fleet bundle: retail

Path: `fleet/retail/`

## What this bundle deploys

- Namespace: `retail`
- Retail Store Sample App from the upstream release manifest:
  - https://github.com/aws-containers/retail-store-sample-app/releases/latest/download/kubernetes.yaml
- Traefik hostless Ingress (any hostname) for the UI: `retail-ui-anyhost`
- Patches the `ui` Service to `ClusterIP` (Ingress owns external exposure)

## Rancher / Fleet usage

1. Rancher UI → Fleet → Git Repos → Add Repository
2. Repo: this repository
3. Branch: `main`
4. Paths: `fleet/retail`
5. Targets: choose the cluster(s)
6. Recommended: enable **Prune**

## Cleanup

- Preferred: delete the GitRepo (or remove targets) with **Prune** enabled
- Hard reset: delete the namespace `retail`
