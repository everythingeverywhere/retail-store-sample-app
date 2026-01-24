## Deploying the Retail Store Sample App with Traefik on SUSE Rancher for AWS

This guide explains how to deploy the Retail Store Sample App on **Amazon EKS clusters managed by SUSE Rancher for AWS**, using **Traefik** as the Ingress controller.

SUSE Rancher for AWS provides a fully managed control plane for **multi-cluster Kubernetes**, including **centralized RBAC**, consistent governance, and visibility across clusters. Once an EKS cluster is connected to Rancher, application deployment follows standard Kubernetes workflows and can be reused consistently across environments.

The application deployment itself is unchanged from the upstream project. The only difference is how the UI service is exposed when Traefik is already installed.

---

### Prerequisites

* One or more Amazon EKS clusters connected to **SUSE Rancher for AWS**
* Traefik installed as the cluster Ingress controller
* RBAC permissions to deploy workloads (managed centrally through Rancher)
* An available IngressClass for Traefik (for example `traefik`)

You can verify the IngressClass from Rancher’s Cluster Explorer or via the CLI:

```bash
kubectl get ingressclass
```

---

### Step 1: Deploy the Application

From **SUSE Rancher for AWS**, deploy workloads using Cluster Explorer or your local `kubectl` context.

Apply the official Kubernetes manifest from the upstream project:

```bash
kubectl apply -f https://github.com/aws-containers/retail-store-sample-app/releases/latest/download/kubernetes.yaml
```

Wait for all deployments to become available:

```bash
kubectl wait --for=condition=available deployments --all
```

SUSE Rancher for AWS provides centralized visibility into deployment status, pod health, logs, and events across all connected clusters.

---

### Step 2: Update the UI Service for Traefik

The default manifest exposes the `ui` service as a LoadBalancer. When using Traefik, the service should remain internal and be routed through an Ingress.

Patch the service to use `ClusterIP`:

```bash
kubectl patch svc ui -p '{"spec":{"type":"ClusterIP"}}'
```

This keeps external access centralized through Traefik and aligns with ingress-based routing best practices.

---

### Step 3: Create a Traefik Ingress Resource

Create a file named `ui-ingress.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: retail-ui
  namespace: default
spec:
  ingressClassName: traefik
  rules:
    - host: retail.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: ui
                port:
                  number: 80
```

Apply the Ingress:

```bash
kubectl apply -f ui-ingress.yaml
```

If your cluster uses a different Traefik IngressClass name, update the `ingressClassName` field accordingly.

---

### Step 4: Configure DNS

Point the hostname used in the Ingress (for example `retail.example.com`) to Traefik’s external address.

Find the Traefik service endpoint:

```bash
kubectl get svc -n traefik
```

Create a DNS A or CNAME record that resolves to this address.

---

### Step 5: Verify Access and RBAC

Using **SUSE Rancher for AWS**, you can verify:

* Application health and rollout status
* Ingress configuration
* User and group access through centralized RBAC

Verify the Ingress resource:

```bash
kubectl get ingress retail-ui
```

Open the configured hostname in a browser to access the Retail Store UI.

---

### Multi-Cluster Usage with SUSE Rancher for AWS

Because SUSE Rancher for AWS provides centralized access control and governance, the same deployment pattern can be reused safely across multiple EKS clusters such as development, staging, and production.

Teams can:

* Apply consistent RBAC policies across clusters
* Reuse the same manifests without modification
* Manage access and visibility from a single control plane

---

### Cleanup

To remove the application and routing configuration:

```bash
kubectl delete -f ui-ingress.yaml
kubectl delete -f https://github.com/aws-containers/retail-store-sample-app/releases/latest/download/kubernetes.yaml
```

---

### Notes

* This guide uses standard Kubernetes Ingress resources for portability.
* Traefik IngressRoute CRDs can also be used if enabled, but are not required.
* TLS can be added using cert-manager or Traefik’s native TLS configuration.
* SUSE Rancher for AWS ensures consistent RBAC and governance across all connected clusters.



//============//

![Banner](./docs/images/banner.png)

<div align="center">
  <div align="center">

[![Stars](https://img.shields.io/github/stars/aws-containers/retail-store-sample-app)](Stars)
![GitHub License](https://img.shields.io/github/license/aws-containers/retail-store-sample-app?color=green)
![Dynamic JSON Badge](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2Faws-containers%2Fretail-store-sample-app%2Frefs%2Fheads%2Fmain%2F.release-please-manifest.json&query=%24%5B%22.%22%5D&label=release)
![GitHub Release Date](https://img.shields.io/github/release-date/aws-containers/retail-store-sample-app)

  </div>

  <strong>
  <h2>AWS Containers Retail Sample</h2>
  </strong>
</div>

This is a sample application designed to illustrate various concepts related to containers on AWS. It presents a sample retail store application including a product catalog, shopping cart and checkout.

It provides:

- A demo store-front application with themes, pages to show container and application topology information, generative AI chat bot and utility functions for experimentation and demos.
- An optional distributed component architecture using various languages and frameworks
- A variety of different persistence backends for the various components like MariaDB (or MySQL), DynamoDB and Redis
- The ability to run in different container orchestration technologies like Docker Compose, Kubernetes etc.
- Pre-built container images for both x86-64 and ARM64 CPU architectures
- All components instrumented for Prometheus metrics and OpenTelemetry OTLP tracing
- Support for Istio on Kubernetes
- Load generator which exercises all of the infrastructure

See the [features documentation](./docs/features.md) for more information.

**This project is intended for educational purposes only and not for production use**

![Screenshot](/docs/images/screenshot.png)

## Application Architecture

The application has been deliberately over-engineered to generate multiple de-coupled components. These components generally have different infrastructure dependencies, and may support multiple "backends" (example: Carts service supports MongoDB or DynamoDB).

![Architecture](/docs/images/architecture.png)

| Component                  | Language | Container Image                                                             | Helm Chart                                                                        | Description                             |
| -------------------------- | -------- | --------------------------------------------------------------------------- | --------------------------------------------------------------------------------- | --------------------------------------- |
| [UI](./src/ui/)            | Java     | [Link](https://gallery.ecr.aws/aws-containers/retail-store-sample-ui)       | [Link](https://gallery.ecr.aws/aws-containers/retail-store-sample-ui-chart)       | Store user interface                    |
| [Catalog](./src/catalog/)  | Go       | [Link](https://gallery.ecr.aws/aws-containers/retail-store-sample-catalog)  | [Link](https://gallery.ecr.aws/aws-containers/retail-store-sample-catalog-chart)  | Product catalog API                     |
| [Cart](./src/cart/)        | Java     | [Link](https://gallery.ecr.aws/aws-containers/retail-store-sample-cart)     | [Link](https://gallery.ecr.aws/aws-containers/retail-store-sample-cart-chart)     | User shopping carts API                 |
| [Orders](./src/orders)     | Java     | [Link](https://gallery.ecr.aws/aws-containers/retail-store-sample-orders)   | [Link](https://gallery.ecr.aws/aws-containers/retail-store-sample-orders-chart)   | User orders API                         |
| [Checkout](./src/checkout) | Node     | [Link](https://gallery.ecr.aws/aws-containers/retail-store-sample-checkout) | [Link](https://gallery.ecr.aws/aws-containers/retail-store-sample-checkout-chart) | API to orchestrate the checkout process |

## Quickstart

The following sections provide quickstart instructions for various platforms.

### Docker

This deployment method will run the application as a single container on your local machine using `docker`.

Pre-requisites:

- Docker installed locally

Run the container:

```
docker run -it --rm -p 8888:8080 public.ecr.aws/aws-containers/retail-store-sample-ui:1.0.0
```

Open the frontend in a browser window:

```
http://localhost:8888
```

To stop the container in `docker` use Ctrl+C.

### Docker Compose

This deployment method will run the application on your local machine using `docker-compose`.

Pre-requisites:

- Docker installed locally

Download the latest Docker Compose file and use `docker compose` to run the application containers:

```
wget https://github.com/aws-containers/retail-store-sample-app/releases/latest/download/docker-compose.yaml

DB_PASSWORD='<some password>' docker compose --file docker-compose.yaml up
```

Open the frontend in a browser window:

```
http://localhost:8888
```

To stop the containers in `docker compose` use Ctrl+C. To delete all the containers and related resources run:

```
docker compose -f docker-compose.yaml down
```

### Kubernetes

This deployment method will run the application in an existing Kubernetes cluster.

Pre-requisites:

- Kubernetes cluster
- `kubectl` installed locally

Use `kubectl` to run the application:

```
kubectl apply -f https://github.com/aws-containers/retail-store-sample-app/releases/latest/download/kubernetes.yaml
kubectl wait --for=condition=available deployments --all
```

Get the URL for the frontend load balancer like so:

```
kubectl get svc ui
```

To remove the application use `kubectl` again:

```
kubectl delete -f https://github.com/aws-containers/retail-store-sample-app/releases/latest/download/kubernetes.yaml
```

### Terraform

The following options are available to deploy the application using Terraform:

| Name                                             | Description                                                                                                     |
| ------------------------------------------------ | --------------------------------------------------------------------------------------------------------------- |
| [Amazon EKS](./terraform/eks/default/)           | Deploys the application to Amazon EKS using other AWS services for dependencies, such as RDS, DynamoDB etc.     |
| [Amazon EKS (Minimal)](./terraform/eks/minimal/) | Deploys the application to Amazon EKS using in-cluster dependencies instead of RDS, DynamoDB etc.               |
| [Amazon ECS](./terraform/ecs/default/)           | Deploys the application to Amazon ECS using other AWS services for dependencies, such as RDS, DynamoDB etc.     |
| [AWS App Runner](./terraform/apprunner/)         | Deploys the application to AWS App Runner using other AWS services for dependencies, such as RDS, DynamoDB etc. |

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This project is licensed under the MIT-0 License.

This package depends on and may incorporate or retrieve a number of third-party
software packages (such as open source packages) at install-time or build-time
or run-time ("External Dependencies"). The External Dependencies are subject to
license terms that you must accept in order to use this package. If you do not
accept all of the applicable license terms, you should not use this package. We
recommend that you consult your company’s open source approval policy before
proceeding.

Provided below is a list of External Dependencies and the applicable license
identification as indicated by the documentation associated with the External
Dependencies as of Amazon's most recent review.

THIS INFORMATION IS PROVIDED FOR CONVENIENCE ONLY. AMAZON DOES NOT PROMISE THAT
THE LIST OR THE APPLICABLE TERMS AND CONDITIONS ARE COMPLETE, ACCURATE, OR
UP-TO-DATE, AND AMAZON WILL HAVE NO LIABILITY FOR ANY INACCURACIES. YOU SHOULD
CONSULT THE DOWNLOAD SITES FOR THE EXTERNAL DEPENDENCIES FOR THE MOST COMPLETE
AND UP-TO-DATE LICENSING INFORMATION.

YOUR USE OF THE EXTERNAL DEPENDENCIES IS AT YOUR SOLE RISK. IN NO EVENT WILL
AMAZON BE LIABLE FOR ANY DAMAGES, INCLUDING WITHOUT LIMITATION ANY DIRECT,
INDIRECT, CONSEQUENTIAL, SPECIAL, INCIDENTAL, OR PUNITIVE DAMAGES (INCLUDING
FOR ANY LOSS OF GOODWILL, BUSINESS INTERRUPTION, LOST PROFITS OR DATA, OR
COMPUTER FAILURE OR MALFUNCTION) ARISING FROM OR RELATING TO THE EXTERNAL
DEPENDENCIES, HOWEVER CAUSED AND REGARDLESS OF THE THEORY OF LIABILITY, EVEN
IF AMAZON HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. THESE LIMITATIONS
AND DISCLAIMERS APPLY EXCEPT TO THE EXTENT PROHIBITED BY APPLICABLE LAW.

MariaDB Community License - [LICENSE](https://mariadb.com/kb/en/mariadb-licenses/)
MySQL Community Edition - [LICENSE](https://github.com/mysql/mysql-server/blob/8.0/LICENSE)
