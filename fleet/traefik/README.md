# Fleet bundle: Traefik (prerequisite)

Path: `fleet/traefik/`

This bundle installs **Traefik** via Helm and exposes it with a `LoadBalancer` Service.

## Deploy with Rancher Fleet

1. Rancher UI → Fleet → Git Repos → Add Repository
2. Repo URL: this repository
3. Branch: `main`
4. Paths: `fleet/traefik`
5. Targets: select your cluster
6. Set **Target Namespace**: `traefik`
7. Enable **Create Namespace**
8. (Recommended) enable cleanup/prune (wording varies by Rancher version)

Wait until the Bundle is **Ready**.

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
