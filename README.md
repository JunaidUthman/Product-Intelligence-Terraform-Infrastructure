# Infrastructure Cloud AWS (Terraform)

Ce dossier contient la configuration **Terraform** complète pour déployer l'infrastructure Cloud AWS pour la plateforme **Product Intelligence**.

---

## 🏗️ Architecture déployée

```text
product-intelligence-terraform-infrastructure/
├── vpc.tf                   # VPC, Subnets publics/privés, NAT Gateway & tags ALB
├── eks.tf                   # Cluster Kubernetes EKS (v1.30) & Managed Node Groups
├── iam.tf                   # Rôles IAM IRSA (AWS Load Balancer Controller + EBS CSI)
├── rds.tf                   # Base de données managée AWS RDS MySQL 8.0 & Security Groups
├── dns.tf                   # Zone DNS privée Route 53 (db.product-intelligence.internal)
├── variables.tf             # Variables configurables (Région, versions, tailles d'instances)
├── outputs.tf               # Sorties utiles (kubectl config, endpoints, IAM roles)
├── terraform.tfvars.example # Modèle pour renseigner vos variables secrètes
├── .gitignore               # Protection contre le commit de tfstate et variables
└── README.md                # Guide complet
```

---

## 🎯 Composants créés

1. **Réseau (VPC & Subnets) :**
   * Multi-AZ avec sous-réseaux publics et privés.
   * **Tags officiels pour l'ALB** : `kubernetes.io/role/elb = 1` et `kubernetes.io/cluster/realestate-prod-cluster = shared`.
   * **Single NAT Gateway** : Partagée pour tous les sous-réseaux privés (permet aux nœuds EKS de télécharger les images tout en évitant de payer un NAT Gateway par AZ).

2. **Cluster Kubernetes Managé (AWS EKS v1.30) :**
   * Control Plane EKS managé avec accès public et privé.
   * **EKS Access Entries** : Accès administrateur automatique sans fichier `aws-auth`.
   * **Managed Node Group** : Instances EC2 situées dans les sous-réseaux privés (sécurisées contre tout accès direct depuis Internet).
   * **Add-ons officiels** : CoreDNS, Kube-Proxy, VPC-CNI et AWS EBS CSI Driver (pour les volumes persistants).

3. **Authentification IAM Cloud-Native (IRSA) :**
   * **Rôle IAM pour AWS Load Balancer Controller** : Permet au contrôleur dans Kubernetes de provisionner et gérer automatiquement les Application Load Balancers sur AWS.
   * **Rôle IAM pour AWS EBS CSI Driver** : Permet de créer dynamiquement des volumes EBS pour les PVCs de vos microservices et de Kubeflow.

4. **Base de Données (AWS RDS MySQL 8.0) & Découverte DNS :**
   * Instance `db.t4g.micro` avec stockage SSD `gp3` (20 Go, Free Tier éligible).
   * **Sécurité Zero-Trust** : Le Security Group autorise directement le groupe de nœuds EKS sur le port 3306.
   * **Route 53 Private DNS** : Résolution automatique via le nom permanent et fixe **`db.product-intelligence.internal`** pour vos pods Kubernetes.

---

## 🚀 Déploiement pas-à-pas

### Étape 1 : Préparer vos variables
```bash
cp terraform.tfvars.example terraform.tfvars
```
Renseignez dans `terraform.tfvars` :
* Votre adresse IP publique (`curl -s ifconfig.me`)
* Votre mot de passe de base de données `db_password`

### Étape 2 : Initialiser et déployer l'infrastructure
```bash
terraform init
terraform plan
terraform apply
```
*(Le déploiement complet d'EKS et RDS prend généralement entre 10 et 15 minutes).*

---

## 🔌 Connexion au Cluster EKS et Déploiement GitOps

### 1. Configurer `kubectl` vers votre nouveau cluster AWS
Terraform fournit la commande exacte dans ses sorties :
```bash
$(terraform output -raw configure_kubectl)
```
Vérifiez que vous êtes connecté :
```bash
kubectl get nodes
```

### 2. Annoter le ServiceAccount de l'AWS Load Balancer Controller avec le rôle IAM
Récupérez l'ARN du rôle IAM généré par Terraform :
```bash
terraform output -raw aws_lbc_role_arn
```
*(Cette valeur est à annoter sur le ServiceAccount `kube-system/aws-load-balancer-controller` ou directement dans `aws-lbc-manifest.yaml`).*

### 3. Appliquer vos secrets
Créez vos secrets sur le nouveau cluster dans le namespace `product-intelligence` :
```bash
kubectl apply -f ../product-intelligence-K8S-infrastructure/base/secrets.yaml
```

### 4. Installer ArgoCD et déclencher le déploiement GitOps
```bash
kubectl apply -k ../product-intelligence-K8S-infrastructure/argocd/install/
kubectl apply -f ../product-intelligence-K8S-infrastructure/argocd/root-app.yaml
```

ArgoCD prend alors le relais et déploie automatiquement l'ensemble de votre cluster en respectant toutes les vagues de synchronisation !
