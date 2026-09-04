# Google Cloud Storage Backend

A GCS Backend stores Terraform state remotely in a Google Cloud Storage (GCS) bucket.

Instead of `terraform.tfstate` on your laptop, Terraform stores state in: `Google Cloud Storage Bucket`

1. Create GCS Bucket
```bash
gsutil mb \
-l northamerica-northeast1 \
gs://terraform-state-prod
```
2. Enable Versioning: Recommended for every Terraform state bucket.
```bash
gsutil versioning set on \
gs://terraform-state-prod
```
---

## Backend Configuration and Parameters

```hcl
terraform {
  backend "gcs" {
    bucket = "terraform-state-prod"
  }
}
```
1. *GCS bucket name*. `bucket = "terraform-state-prod"`
2. *prefix*: Folder path inside bucket.
```hcl
backend "gcs" {

  bucket = "terraform-state-prod"
  prefix = "network"

}
```
State stored in: `terraform-state-prod/network/`
3. credentials (Optional) `credentials = "sa.json"`, Service account credentials.
    - Usually unnecessary when using: `gcloud auth application-default login`

---

## Migrating Local State to GCS

1. Current: `terraform.tfstate`
2. Add backend:
```hcl
terraform {
  backend "gcs" {
    bucket = "terraform-state-prod"
  }
}
```
3. Run: `terraform init`
    * Terraform asks: *Do you want to copy existing state?* - `yes`
4. Terraform uploads state.

---

## Backend Reconfiguration

1. Suppose bucket changes.
```hcl
#Old:
bucket = "terraform-state-dev"

#New:
bucket = "terraform-state-prod"
```

2. Run: `terraform init -reconfigure`
3. Terraform reloads backend settings.

---

## State Storage Strategy

```text
terraform-state/

├── dev/
│   ├── network/
│   └── gke/
│
├── test/
│   ├── network/
│   └── gke/
│
└── prod/
    ├── network/
    └── gke/
```

Using:

```hcl
prefix = "prod/network"
```
---

## GCS Behavior

GCS backend supports ***state locking*** through generation-based protection.

Terraform prevents simultaneous conflicting state updates.

```text
User A
     ↓
State Update In Progress

User B
     ↓
Must Wait / Retry
```
---

***Interview Keywords:***
```text
GCS Backend
Remote State
State Migration
Versioning
Centralized State
Terraform Collaboration
State Storage
```