# Fleet bundle: retail

Path: `fleet/retail/`

## Prerequisite

This bundle assumes an Ingress controller is installed.
For this demo we assume **Traefik** with an IngressClass named `traefik`.

If Traefik is not installed yet, install it first using the included Fleet bundle:

- `fleet/traefik/`

## What this bundle deploys

- Retail Store Sample App from the upstream release manifest:
  - https://github.com/aws-containers/retail-store-sample-app/releases/latest/download/kubernetes.yaml
- Traefik hostless Ingress (any hostname) for the UI: `retail-ui-anyhost`
- Patches the `ui` Service to `ClusterIP` (Ingress owns external exposure)

## Rancher / Fleet usage (step-by-step)

### A) Install Traefik first (one-time per cluster)

If Traefik is already installed in the cluster, skip this.

1. Rancher UI → Fleet → Git Repos → Add Repository
2. Name: `traefik-demo`
3. Repo URL: this repository
4. Branch: `main`
5. Paths: `fleet/traefik`
6. Targets: select your cluster
7. Target Namespace: `traefik` and enable **Create Namespace**
8. Save and wait until it is **Ready**

### B) Deploy the retail app

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

### C) Watch it sync

1. Click into the created GitRepo (`retail-demo`)
2. Confirm status becomes **Ready / Synced**
3. Click the created **Bundle** (or Bundles tab) to see rollout details

### D) Ensure the namespace exists (important)

If the namespace `retail` already exists from a previous install, Fleet/Helm may refuse to "adopt" it.

Fastest demo fix:

- Delete the namespace and re-install (see Cleanup → Hard reset)

Or, when creating the GitRepo in Fleet, set:

- **Target Namespace**: `retail`
- **Create Namespace**: ON

### E) Verify the app in Cluster Explorer

1. Go to **Cluster Explorer** for your target cluster
2. Select namespace: `retail`
3. Verify resources:
   - Workloads/Deployments: app components are running
   - Service Discovery → **Ingresses**: `retail-ui-anyhost`
   - Service Discovery → **Services**: `ui` is `ClusterIP`

### F) Open the UI (Traefik LoadBalancer) — hostless demo

Because this bundle applies a **hostless Ingress** (`retail-ui-anyhost`), you can access the app using the raw Traefik LoadBalancer DNS name (no DNS or `/etc/hosts` needed).

#### Get the Traefik LoadBalancer hostname

**From Rancher UI**

1. Cluster Explorer → **Service Discovery → Services**
2. Switch namespace to `traefik` (or wherever Traefik is installed)
3. Click service `traefik`
4. Copy the **External IP / Hostname** (AWS ELB hostname)

**From kubectl** (namespace/service may differ in your environment):

```bash
kubectl get svc traefik -n traefik
```

Look under **EXTERNAL-IP** for the ELB hostname.

#### Open the app

Open in a browser:

```text
http://<TRAEFIK-ELB-DNS-NAME>/
```

Example:

```text
http://ac5ebc48aa4534ff8b4583e88ed6ac90-502276271.us-east-2.elb.amazonaws.com/
```

## Cleanup (automated)

If you hit an error about namespace ownership/Helm metadata ("Namespace exists and cannot be imported"), it means `retail` already exists but wasn’t created by this Fleet release.
For demos, the simplest fix is deleting that namespace and reinstalling.

### Option 1 (recommended): Fleet-managed uninstall

- Fleet → Git Repos → select `retail-demo` → **Delete**
- Ensure **Prune** was enabled (so Fleet deletes the resources it previously applied)

### Option 2: Hard reset (always deletes everything)

Delete the namespace (removes all resources in `retail`):

```bash
kubectl delete namespace retail
```
