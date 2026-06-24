Step 1: Clone the GitHub Repository
Open VS Code → Terminal → Run:

git clone https://github.com/ChSaiteja123/Microservices-E-Commerce-eks-project.git

aws configure

cd <project-folder>

create s3 buckets using terraform
store files for collabaration

- cd s3-buckets/
- terraform init
- terraform plan
- terraform apply -auto-approve

create infra 

- cd ../terraform_main_ec2
- terraform init
- terraform plan
- terraform apply -auto-approve

Sample output:

Apply complete! Resources: 24 added, 0 changed, 0 destroyed.
jumphost_public_ip = "18.208.229.108"
region = "us-east-1"



Verify installed DevOps tools:

- git --version
- java -version
- jenkins --version
- terraform -version
- mvn -v
- kubectl version --client --short
- eksctl version
- helm version --short
- docker --version
- trivy --version


login to jenkins 
<ip:8080>
cat /var/lib/jenkins/secrets/initialAdminPassword

create password

install plugins
- pipeline : stage view

Create a Jenkins Pipeline Job (Create EKS Cluster)

- src : https://github.com/ChSaiteja123/Microservices-E-Commerce-eks-project.git
- branch: */master
- eks-terraform/eks-jenkinsfile

params:

- apply
- destroy 
- apply and save


Create a Jenkins Pipeline Job (ECR)

params:

- apply
- destroy 
- apply and save

- src : https://github.com/ChSaiteja123/Microservices-1.git
- branch: */master
- ecr-terraform/ecr-jenkinsfile

- apply and save

verify ecr

aws ecr describe-repositories --region us-east-1

Services:

emailservice
checkoutservice
recommendationservice
frontend
paymentservice
productcatalogservice
cartservice
loadgenerator
currencyservice
shippingservice
adservice


Create a Jenkins Pipeline Job for Build and Push Docker Images to ECR

Navigate to Jenkins Dashboard → Manage Jenkins → Credentials → (global) → Global credentials (unrestricted).
Click “Add Credentials”.


Jenkins Pipeline Setup: Build and Push and update Docker Images to ECR

Jenkins Pipeline Setup: emailservice

multibranch pipeline

- src : https://github.com/ChSaiteja123/Microservice-1.git
- branch: */master
- jenkinsfile

Microservices

- emailservice
- checkoutservice
- recommendationservice
- frontend
- paymentservice
- productcatalogservice
- cartservice
- loadgenerator
- currencyservice
- shippingservice
- adservice

Create a Jenkins Pipeline Job for Build and Push Docker Images to ECR


Install ArgoCD in Jumphost EC2

kubectl create namespace argocd

 Install ArgoCD in the Created Namespace

kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml


kubectl get pods -n argocd

Validate the Cluster

kubectl get nodes

 List All ArgoCD Resources

kubectl get all -n argocd

kubectl edit svc argocd-server -n argocd

Change the Service Type

Find this line:

type: ClusterIP
Change it to:
type: LoadBalancer

kubectl get svc argocd-server -n argocd

 Access the ArgoCD UI

Use the DNS:

https://<EXTERNAL-IP>.amazonaws.com


Get the Initial ArgoCD Admin Password

kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath="{.data.password}" | base64 -d && echo


Deploying with ArgoCD and Configuring Route 53

kubectl create namespace dev
kubectl get namespaces



Step 15.2: Create New Applicatio with ArgoCD

Open the ArgoCD UI in your browser.
Click + NEW APP.
Fill in the following:
Application Name: project
Project Name: default
Sync Policy: Automatic
Repository URL: https://github.com/ChSaiteja123/Microservice-1.git
Revision: HEAD
Path: kubernetes-files
Cluster URL: https://kubernetes.default.svc
Namespace: dev
Click Create.


 Create a Jenkins Pipeline Job for Backend and frondend & Route 53 Setup


 Prometheus & Grafana

Prerequisites (Before We Start)
Make sure you have these ready 👇
1️. A Kubernetes Cluster (EKS, GKE, Minikube — anything works)
2️. kubectl is installed and connected to your cluster ✅
3️. Helm is installed (helm version)

helm installation

# Install Helm (if not installed)
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
helm version


kubectl create namespace monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update


Install the Kube Prometheus Stack (Includes Prometheus + Grafana)

helm install kube-prom-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring

  verify 
  kubectl get pods -n monitoring

  Accessing the Grafana UI Using LoadBalancer

  kubectl edit svc kube-prom-stack-grafana -n monitoring
  type: ClusterIP
  type: LoadBalancer

  kubectl get svc kube-prom-stack-grafana -n monitoring


Accessing the Grafana UI

kubectl get secret kube-prom-stack-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 -d && echo # password


op: prom-operator

Add Kubernetes Dashboards in Grafana

Kubernetes Cluster Monitoring (ID: 315)
Kubernetes Pods/Containers (ID: 3662)
Kubernetes Deployments (ID: 1621)
Kubernetes API Server (ID: 12006)
Kubernetes Nodes (ID: 6417)
Kubernetes Namespace Monitoring (ID: 10000)
Kubernetes Persistent Volumes (ID: 13602)
Kubernetes Networking (ID: 15758)
NGINX Ingress Controller (ID: 9614)


 Configure Alerts (Email Notifications)

 kubectl get pods -n monitoring

 verify 
 alertmanager-kube-prom-stack-kube-prome-alertmanager-0       
✅ If it’s running, you’re good to go.


kubectl get pods -n monitoring | grep alertmanager


kubectl get pods -n monitoring | grep alertmanager

type: ClusterIP
type: LoadBalancer

 Port 9093

 kubectl get secret alertmanager-kube-prom-stack-kube-prome-alertmanager -n monitoring -o jsonpath='{.data.alertmanager\.yaml}' | base64 --decode > alertmanager.yaml


vim alertmanager.yaml


global:
  smtp_smarthost: 'smtp.gmail.com:587'      # Your SMTP server
  smtp_from: 'saitej@hmail.com'         # Sender email
  smtp_auth_username: 'saitej@gmai.com'
  smtp_auth_password: 'your-app-password'   # Use app password (not your real password!)

route:
  receiver: 'email-alert'

receivers:
  - name: 'email-alert'
    email_configs:
      - to: 'saitej@gmail.com'      # Where to send alerts
        send_resolved: true



Enable “Less Secure Apps” or create an App Password from Google account security settings.

kubectl create secret generic alertmanager-kube-prom-stack-kube-prome-alertmanager \
  --from-file=alertmanager.yaml \
  -n monitoring \
  --dry-run=client -o yaml | kubectl apply -f -


  kubectl delete pod alertmanager-kube-prom-stack-kube-prome-alertmanager-0 -n monitoring


  kubectl get pods -n monitoring -w

  Create an Alert Rule (CPU Example)

  vim cpu-alert-rule.yaml

