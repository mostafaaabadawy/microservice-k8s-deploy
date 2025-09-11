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
Output:
```bash
CONTAINER ID   IMAGE              COMMAND           CREATED         STATUS                     PORTS     NAMES
780ab4e64927   microservice-app   "python run.py"   9 seconds ago   Exited (1) 5 seconds ago             focused_galois
```
> ⚠️ Note: Fix `werkzeug` version to `==2.2.2` in `requirements.txt` to resolve runtime errors.

---

### 📦 Push Image to DockerHub

Create a DockerHub registry and push the image:

```bash
docker push mostafaaabadawy/microservice-app:latest
```

Repository: [GitHub - microservice-k8s-deploy](https://github.com/mostafaaabadawy/microservice-k8s-deploy)

Output:
```bash
The push refers to repository [docker.io/mostafaaabadawy/microservice-app]
2dc9465ac3aa: Pushed
459f38fc73fd: Pushed
41dc2499d8fe: Pushed
1d454ace0e38: Pushed
ce1261c6d567: Pushed
6abc6fb9d77e: Pushed
5994c0fbe528: Pushed
7fcdf9369fa9: Pushed
a2c65383a5a3: Pushed
latest: digest: sha256:ce7d23ff44e2abb47b80b66fa777959823bb45b68924a0bf9cb8336ff01747c6 size: 856
```

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
Output:
```bash
mostafa [ ~ ]$ kubectl get ingress
NAME                   CLASS   HOSTS                ADDRESS         PORTS   AGE
microservice-ingress   nginx   microservice.local   57.152.95.203   80      73s
mostafa [ ~ ]$ kubectl get all
NAME                                           READY   STATUS    RESTARTS   AGE
pod/microservice-deployment-8567bcb7c9-5tj4g   1/1     Running   0          9m
pod/microservice-deployment-8567bcb7c9-xfdtf   1/1     Running   0          9m

NAME                           TYPE           CLUSTER-IP   EXTERNAL-IP     PORT(S)        AGE
service/kubernetes             ClusterIP      10.0.0.1     <none>          443/TCP        19m
service/microservice-service   LoadBalancer   10.0.71.53   74.179.254.97   80:30240/TCP   8m53s

NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/microservice-deployment   2/2     2            2           9m

NAME                                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/microservice-deployment-8567bcb7c9   2         2         2       9m
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

Run the workflow and verify pods are created.  Workflow run logs are available in the github files.

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
