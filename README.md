# Infrastructure Cloud AWS (Terraform) — Phase 1

Ce dossier contient la configuration **Terraform** pour déployer l'infrastructure Cloud AWS du projet **Product Intelligence**.

---

## 🎯 Objectif de la Phase 1

1. **Créer le VPC et les sous-réseaux (Publics et Privés)** :
   * Tagués pour supporter le futur cluster EKS et l'**AWS Application Load Balancer (ALB)**.
2. **Provisionner une base de données managée AWS RDS MySQL** :
   * `publicly_accessible = true` temporairement.
   * **Sécurisée** par un Security Group n'autorisant les connexions que depuis **votre adresse IP publique locale**.
3. **Tester et valider la connexion** depuis votre setup local (Minikube / scripts de migration).

---

## 🚀 Déploiement pas-à-pas

### Étape 1 : Configurer vos identifiants AWS
Assurez-vous que l'AWS CLI est configurée sur votre machine :
```bash
aws sts get-caller-identity
```

### Étape 2 : Préparer vos variables
1. Copiez le fichier d'exemple :
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
2. Obtenez votre adresse IP publique :
   ```bash
   curl -s ifconfig.me
   ```
3. Éditez `terraform.tfvars` :
   * Renseignez `my_ip_address = "<VOTRE_IP>/32"`
   * Définissez un mot de passe sécurisé pour `db_password`.

### Étape 3 : Initialiser et déployer avec Terraform
```bash
terraform init
terraform plan
terraform apply
```
*(La création du RDS MySQL prend généralement environ 5 à 7 minutes).*

---

## 🔍 Récupérer les informations de connexion

Une fois `terraform apply` terminé, Terraform affiche les sorties (*outputs*) :
```bash
terraform output rds_host
```

Pour afficher l'URL complète prête à l'emploi (avec le mot de passe) :
```bash
terraform output -raw database_url_example; echo
```

---

## 🔄 Connecter votre cluster local (Minikube) à la base RDS

Dans votre dossier `product-intelligence-K8S-infrastructure/base/` :

1. **Mettre à jour `secrets.yaml` :**
   Remplacer la valeur `DATABASE_URL` par l'URL fournie par Terraform :
   ```yaml
   DATABASE_URL: "mysql://appuser:<VOTRE_MOT_DE_PASSE>@<RDS_HOST>:3306/product_intelligence"
   ```

2. **Mettre à jour `configmap.yaml` :**
   ```yaml
   MYSQL_HOST: "<RDS_HOST>"
   ```

3. **Appliquer les secrets sur Minikube :**
   ```bash
   kubectl apply -f base/secrets.yaml
   ```

Votre plateforme locale écrit et lit désormais directement sur votre base AWS RDS dans le cloud !

---

## ☕ Phase 2 (Prochaine étape)
Une fois la base testée et validée, nous ajouterons les fichiers `eks.tf` et `iam.tf` pour déployer le cluster Kubernetes AWS managé et laisser ArgoCD orchestrer l'ensemble.

