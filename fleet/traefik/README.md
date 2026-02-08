# Fleet bundle: Traefik (prerequisite)

Path: `fleet/traefik/`

This bundle installs **Traefik** via Helm and exposes it with a `LoadBalancer` Service.

It is configured with **namespaced RBAC** (`rbac.namespaced=true`) so it can be deployed even when Fleet GitRepo settings restrict cluster-scoped resources.

## Deploy with Rancher Fleet

1. Rancher UI → Fleet → Git Repos → Add Repository
2. Repo URL: this repository
3. Branch: `main`
4. Paths: `fleet/traefik`
5. Targets: select your cluster
6. Ensure the Traefik bundle deploys into namespace `traefik` (Fleet will use the bundle namespace settings).

Wait until the Bundle is **Ready**.

## Common error: cluster-scoped resources forbidden

If you see an error like:

> invalid cluster scoped object ... Your config uses targetNamespace or namespace and thus forbids cluster-scoped resources

This bundle is configured to avoid that by using namespaced RBAC (`rbac.namespaced=true`).
If you still hit it, make sure your Fleet GitRepo is not forcing a Target Namespace.

## Verify

```bash
kubectl get ns traefik
kubectl get pods -n traefik
kubectl get svc -n traefik traefik -o wide
kubectl get ingressclass
```

The `traefik` service should show an AWS ELB hostname under EXTERNAL-IP.

## Next

Deploy the retail demo bundle: `fleet/retail/`.
