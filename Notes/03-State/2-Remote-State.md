# Remote State

Remote State means storing Terraform state in a shared remote location instead of keeping it on a local machine.

State is stored in:
- Google Cloud Storage (GCS)
- AWS S3
- Azure Storage Account
- Terraform Cloud

## Backend Configuration

```hcl
terraform {
  backend "gcs" {
    bucket = "terraform-state-prod"
    prefix = "IaC"
  }
}

Bucket: terraform-state-prod
Path: IaC/
```
After backend configuration: `terraform init`
- Connects To Bucket
- Initializes Backend
- Stores State Remotely

```text
terraform-state-prod

# Possible structure:
terraform-state-prod/

├── network/
│   └── terraform.tfstate
│
├── gke/
│   └── terraform.tfstate
│
└── prod/
    └── terraform.tfstate
```
---

![working](https://media.licdn.com/dms/image/v2/D4E10AQHNr6RifWBveg/image-shrink_1280/B4EZZNtd10HkAM-/0/1745060493440?e=2147483647&v=beta&t=a3ec9L21yqC88I9T0fUXW-AxZ0GQVEc73WoTUxggqrc)

## GCP Security Best Practices

1. Keep a Dedicated State Bucket and Do not mix with application data.
2. Enable Bucket Versioning to protect against accidental deletion, bad updates.
3. Restrict IAM Access: Only Terraform users should access state.
4. Encrypt Data: GCS provides encryption by default.

---

## Common Errors

1. Bucket Does Not Exist
2. Authentication Failure
3. Incorrect Bucket Name
4. Backend Configuration Changed

---

## Best Practices

1. Always Use Remote State For Teams
2. Use Separate Buckets/Prefixes like `dev/, test/, prod/`
3. Enable Versioning
4. Restrict Access
5. ***Never Store State In `Git`***
6. Use **CI/CD** With Remote State

```text
GitHub Actions
Cloud Build
Jenkins
Azure DevOps
```

All use the same state backend.

---

# Real GCP Example

Create bucket:

```bash
gsutil mb \
gs://terraform-state-prod
```

Enable versioning:

```bash
gsutil versioning set on \
gs://terraform-state-prod
```

Backend:

```hcl
terraform {

  backend "gcs" {

    bucket = "terraform-state-prod"
    prefix = "gke"

  }

}
```

Initialize:

```bash
terraform init
```

Result:

```text
State Stored In GCS
```

---

***Interview Keywords:***
```text
Remote Backend
Centralized State
State Locking
GCS Backend
Collaboration
Versioning
Single Source of Truth
```