# Terraform State Bootstrap

Ce dossier permet de créer de manière 100 % déclarative le bucket **Amazon S3** qui hébergera le fichier d'état (*remote state*) et le verrouillage natif (*lock*) de notre infrastructure principale.

---

## 🚀 Déploiement (À exécuter une seule fois au tout début)

```bash
cd product-intelligence-terraform-infrastructure/bootstrap
terraform init
terraform apply
```

Une fois terminé, Terraform affichera le nom exact de votre bucket (ex: `product-intelligence-tfstate-123456789012`).

---

## 🔒 Caractéristiques de sécurité du bucket créé :
* **Nom unique** généré automatiquement avec votre numéro de compte AWS (`product-intelligence-tfstate-<ACCOUNT_ID>`).
* **Versioning activé** : Conservation de l'historique de tous vos states (permet de restaurer l'infrastructure en cas de corruption).
* **Chiffrement serveur activé (AES256)** : Données chiffrées au repos.
* **Blocage strict des accès publics** : Le bucket est complètement privé et inaccessible depuis Internet.
* **Protection contre la destruction accidentelle** (`prevent_destroy = true`).

