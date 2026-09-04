# State Migration

State Migration is the process of moving Terraform state from one location to another while preserving Terraform's management of infrastructure.

Terraform continues managing the same infrastructure without recreating resources.

### Why State Migration is Needed

Common scenarios:
1. Local State → Remote State
2. One GCS Bucket → Another GCS Bucket
3. Backend Change
4. State Reorganization
5. Environment Separation

> Before any migration backup the state `cp terraform.tfstate terraform.tfstate.backup` Always keep a recovery copy.
---

### Local State to GCS Migration

1. Current local state `terraform.tfstate` which is stored locally.
2. Add backend configuration.
```hcl
terraform {
  backend "gcs" {
    bucket = "terraform-state-prod"
    prefix = "network"
  }
}
```
3. Run `terraform init`, Terraform detects ***Backend Configuration Changed***.
    * "Do you want to copy existing state to the new backend?" -> 'yes'
4. Terraform uploads state. `local state -> GCS Backend`

---

### Migrating Between GCS Buckets

1. old bucket `terraform-state-dev` and new bucket `terraform-state-prod`
2. Update the backend configuration with the new bucket name.
```hcl
backend "gcs" {
  bucket = "terraform-state-prod"
}
```
3. Run `terraform init`, Terraform migrates state.

---

1. Terraform uses `terraform init` for state migration. Most migrations occur through initialization.
2. Using `-migrate-state` flag for Explicit migration. `terraform init -migrate-state` it Forces State Migration. Useful when moving between backends.
3. Using `-reconfigure` flag reload backend configuration but doesn't ***Automatically migrate state** use when you don't need migration. 

## State Migration Verification

1. After the migration step use `terraform state list` to list resources to valid the infrastructure. 
2. Run `terraform plan` and it should show ***NO CHANGES***, This confirms the migration succeeded.

---

## State Migration Risks

1. Interrupted Migration because of network failure or terminal closed but can we can resolve it by Retrying th Migration.
2. Incorrect Backend: State may migrate to the wrong location but always verify backend settings.
3. Missing Permissions/Permissions Denied: Terraform cannot write state. Verify IAM permissions.

---

### State Migration vs State Move

#### State Migration: Moving the Backend
State migration transfers your entire infrastructure registry from its current storage system to a new one

- **When to use it**:Moving from a local `terraform.tfstate` file to a remote team backend 
- **Switching cloud storage providers** (e.g., migrating from AWS S3 to Google Cloud Storage).

**How it works**: You change the backend block in your configuration files. When you run `terraform init -migrate-state`, Terraform prompts you to automatically copy your existing state history into the newly defined backend destination.

#### State Move: Modifying Resource Tracks
A state move updates the pointer that connects your Terraform code names to the actual assets living in your cloud environment. 

**When to Use it**
- Renaming a resource block in your code without forcing Terraform to delete and rebuild it.
- Refactoring your infrastructure by pushing individual resources inside a newly created module.
- Splitting a monolithic state file into separate, smaller state files.

**How it Works**
- Modern Way (Declarative): Define a *moved* block in your configuration. This keeps your history tracked in git and runs cleanly across team CI/CD pipelines.
- Legacy Way (Imperative): Execute the CLI command `terraform state mv [source_address] [destination_address]` to immediately alter the state registry on the fly.

---

### Best Practices

1. Backup State Before Migration
2. Verify Backend Configuration
3. Run terraform plan After Migration
4. Use Remote State for Teams
5. Enable Bucket Versioning

---

***Interview Keywords:***
```text
State Migration
Backend Migration
Local to Remote State
GCS Backend
terraform init
State Preservation
```