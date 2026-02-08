# Fleet bundle: retail

Path: `fleet/retail/`

## What this bundle deploys

- Namespace: `retail`
- Retail Store Sample App from the upstream release manifest:
  - https://github.com/aws-containers/retail-store-sample-app/releases/latest/download/kubernetes.yaml
- Traefik hostless Ingress (any hostname) for the UI: `retail-ui-anyhost`
- Patches the `ui` Service to `ClusterIP` (Ingress owns external exposure)

## Rancher / Fleet usage (step-by-step)

### A) Deploy to a single cluster

1. In Rancher UI, go to **Fleet** → **Git Repos**
2. Click **Add Repository**
3. Fill in **Repository Details**:
   - **Name**: `retail-demo` (any name is fine)
   - **Repo URL**: `https://github.com/everythingeverywhere/retail-store-sample-app.git`
     - (SSH URL also works if your Rancher/Fleet has access: `git@github.com:everythingeverywhere/retail-store-sample-app.git`)
   - **Branch**: `main`
   - **Paths**: `fleet/retail`
4. (Recommended) Enable:
   - **Prune**: ON (so cleanup is automatic when you delete/disable)
   - **Polling**: leave default
5. Under **Targets**, select the cluster you want (EKS cluster managed by SUSE Rancher for AWS)
6. Click **Create** / **Save**

### B) Watch it sync

1. Click into the created GitRepo (`retail-demo`)
2. Confirm status becomes **Ready / Synced**
3. Click the created **Bundle** (or Bundles tab) to see rollout details

### C) Verify the app in Cluster Explorer

1. Go to **Cluster Explorer** for your target cluster
2. Select namespace: `retail`
3. Verify resources:
   - Workloads/Deployments: app components are running
   - Service Discovery → **Ingresses**: `retail-ui-anyhost`
   - Service Discovery → **Services**: `ui` is `ClusterIP`

### D) Open the UI (Traefik LoadBalancer)

1. Find the Traefik service external address (often in namespace `traefik`, service `traefik`):
   - Cluster Explorer → Service Discovery → Services → namespace `traefik` → service `traefik`
2. Copy the **LoadBalancer hostname** and open:

```
http://<TRAEFIK-LB-HOSTNAME>/
```

## Cleanup (automated)

### Option 1 (recommended): Fleet-managed uninstall

- Fleet → Git Repos → select `retail-demo` → **Delete**
- Ensure **Prune** was enabled (so Fleet deletes the resources it previously applied)

### Option 2: Hard reset (always deletes everything)

Delete the namespace (removes all resources in `retail`):

```bash
kubectl delete namespace retail
```
