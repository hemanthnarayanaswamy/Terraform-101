# Module 2 - Terraform Provider Setup and First GCP Resource

## 1. What Terraform Needs Before It Can Work

Terraform needs three things:

1. **Configuration**
   - The `.tf` files where you describe what infrastructure you want.

2. **Provider**
   - The plugin that knows how to talk to a platform.
   - For GCP, the provider is `hashicorp/google`.

3. **Credentials**
   - Terraform must be authenticated so it can call GCP APIs.
   - For local learning, `Application Default Credentials` are common:

```bash
gcloud auth application-default login
```

---

## 2. Terraform Is Declarative
Terraform compares:

- Your desired state from `.tf` files
- The current state from the state file `remote or local`, which maps to real infrastructure in GCP

Then Terraform decides what actions are needed.

This is why `terraform plan` is very important. *It shows what Terraform is about to do before it does it.*

---

## 3. Basic Terraform Project Files

For a beginner project, use this structure:

```text
module-2-first-gcp-resource/
|-- versions.tf
|-- providers.tf
|-- variables.tf
|-- main.tf
|-- outputs.tf
|-- terraform.tfvars.example
```

### `versions.tf`

This file says:
- Which Terraform version the project expects
- Which provider plugins are needed

Example:

```hcl
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0"
    }
  }
}
```

### `providers.tf`

This file configures the provider.

For GCP, Terraform usually needs:

- Project ID
- Region
- Sometimes zone

Example:

```hcl
provider "google" {
  project = var.project_id
  region  = var.region
}
```

### `variables.tf`

Variables are inputs. **Here we only declare the variable names**

They make your Terraform code reusable instead of hardcoded.

Example:

```hcl
variable "project_id" {
  description = "The GCP project ID."
  type        = string
}
```

### `main.tf`

This file usually contains the resources.

Example:

```hcl
resource "google_storage_bucket" "learning" {
  name     = var.bucket_name
  location = var.bucket_location
}
```

### `outputs.tf`

Outputs print useful values after Terraform creates resources.

Example:

```hcl
output "bucket_url" {
  value = "gs://${google_storage_bucket.learning.name}"
}
```
### `terraform.tfvars`

Terraform .tfvars files are a powerful way to manage variable assignments systematically in Infrastructure as Code (IaC) projects. They can have the extensions `.tfvars` or `.tfvars.json`

- To create a `.tfvars` file, you simply need to define the *variables* and their values in the file. 
- 
To manage different configurations for multiple environments, you can create separate .tfvars files for each environment. For example, you can create `dev.tfvars` and `prod.tfvars` files:

```bash
# dev.tfvars
instance_type = "t2.large"
# prod.tfvars
instance_type = "t2.xlarge"

terraform plan -var-file="dev.tfvars"
terraform plan -var-file="prod.tfvars"
```
Terraform can automatically load `.tfvars` files if they are named `terraform.tfvars or terraform.tfvars.json`. Additionally, any files with names ending in `.auto.tfvars or .auto.tfvars.json` will also be automatically loaded.

```bash
# Rename dev.tfvars to dev.auto.tfvars
mv dev.tfvars dev.auto.tfvars

# Run terraform plan
terraform plan
```
Terraform loads variables in the following order, with later sources taking precedence over earlier ones.

---

## 4. Important Terraform Terms in This Module

### Resource

A resource is something Terraform creates or manages.

```hcl
resource "google_storage_bucket" "learning" {
  name     = var.bucket_name
  location = var.bucket_location
}

resource "google_storage_bucket" "learning"
          |                      |
          |                      local Terraform name
          resource type
```

- `google_storage_bucket` is the provider resource type.
- `learning` is the local name inside Terraform.

Terraform address: `google_storage_bucket.learning`

### Variable
Variables are input values.

```hcl
var.project_id
var.region
var.bucket_name
```
### Output
Outputs are values Terraform prints after apply.

```hcl
output "bucket_name" {
  value = google_storage_bucket.learning.name
}
```
### State
Terraform state remembers what Terraform created.

```text
google_storage_bucket.learning -> real GCP bucket name
```

Without state, *Terraform would not know which real cloud resource belongs to which Terraform resource block.*

---

## 5. The Core Terraform Workflow

### Step 1: `terraform init`
Initializes the working directory.

It downloads the provider plugin and creates the `.terraform/` directory.

Run this once when:
- Starting a new Terraform project
- Adding a new provider
- Changing backend configuration

### Step 2: `terraform fmt`
Formats Terraform files. 

Use this often. Clean formatting matters.

### Step 3: `terraform validate`
Checks whether the configuration is *valid Terraform syntax and structure*. 

### Step 4: `terraform plan`
*Shows what Terraform will do.*

**Imporant Plan symbols:**

```bash
+ create
~ update
- destroy
-/+ destroy and recreate
```
As a beginner, read the plan slowly. Do not skip it.

### Step 5: `terraform apply`
Creates or changes real infrastructure.

Terraform will ask for confirmation.


### Step 6: `terraform destroy`
Deletes the infrastructure managed by this Terraform configuration.

Use this after practice to avoid leaving unused cloud resources.

---

### Things not to commit into the GitHub

```bash
.terraform/
*.tfstate
*.tfstate.*
crash.log
override.tf
override.tf.json
*_override.tf
*_override.tf.json
terraform.tfvars
```