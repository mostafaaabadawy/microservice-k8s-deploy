# microservice-k8s-deploy
---

# 🛠️ Microservice Deployment on Kubernetes (Azure)

This guide walks through deploying a Python microservice to an Azure Kubernetes Service (AKS) cluster using Docker, Terraform, GitHub Actions, and Azure Monitor.

---

## 📁 Repository Setup

Clone the original microservice codebase:

```bash
git clone https://github.com/sameh-Tawfiq/Microservices
cd Microservices
```

---

## 🚀 Step-by-Step Deployment Guide

### 🐳 Dockerize the Python Microservice

Create a `Dockerfile` in the root directory:

```Dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python", "run.py"]
```

Build and test the image locally:

```bash
docker build -t microservice-app .
docker run -p 5000:5000 microservice-app
```

Check container status:

```bash
docker ps -a
```

> ⚠️ Note: Fix `werkzeug` version to `==2.2.2` in `requirements.txt` to resolve runtime errors.

---

### 📦 Push Image to DockerHub

Create a DockerHub registry and push the image:

```bash
docker push mostafaaabadawy/microservice-app:latest
```

Repository: [GitHub - microservice-k8s-deploy](https://github.com/mostafaaabadawy/microservice-k8s-deploy)

---

### 🌐 Provision AKS Cluster with Terraform

Create a `terraform/` directory with:

- `main.tf`
- `cluster.tf`
- `variables.tf`
- `outputs.tf`

Login and set subscription:

```bash
az login --use-device-code
az account set --subscription <subID>
```

Provision the cluster:

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

Configure `kubectl`:

```bash
az aks get-credentials --resource-group microservice-rg --name microservice-aks
kubectl get nodes
```

---

### 📄 Kubernetes Deployment

Create a `kubernetesyaml/` directory with:

- `deployment.yaml`
- `service.yaml`

Apply manifests:

```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

---

### 🌍 Ingress Setup

Deploy NGINX Ingress Controller:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.0/deploy/static/provider/cloud/deploy.yaml
```

Create and apply `ingress.yaml`:

```bash
kubectl apply -f ingress.yaml
```

Verify ingress and resources:

```bash
kubectl get ingress
kubectl get all
```

---

### 🔁 CI/CD with GitHub Actions

Create `.github/workflows/deploy.yml` and configure secrets:

- DockerHub token
- DockerHub username
- Azure service principal credentials:

```bash
az ad sp create-for-rbac \
  --name "github-actions-sp" \
  --role Contributor \
  --scopes "/subscriptions/<subID>/resourceGroups/microservice-rg/providers/Microsoft.ContainerService/managedClusters/microservice-aks" \
  --sdk-auth
```

Run the workflow and verify pods are created.

---

### 📊 Monitoring Stack

Enable Azure Monitor for AKS:

```bash
az aks enable-addons \
  --addon monitoring \
  --name microservice-aks \
  --resource-group microservice-rg
```

This enables container insights and sends metrics/logs to Log Analytics Workspace.

---
