# `terraform init`
Initializes a Terraform working directory.

It prepares Terraform to work with:
- Providers
- Modules
- Backends
- Dependency Lock Files

## What Does It Do?

### 1. Initializes Backend
If you are just starting out, it sets up a ***local file***. 
- If your team uses a ***remote backend*** (like *Amazon S3, Azure Blob, Google Cloud Storage or HashiCorp Cloud*), `init` establishes a secure connection to that remote storage and sets up state locking mechanisms.

```hcl
terraform {
  backend "gcs" {
    bucket = "terraform-state"
  }
}
```

### 2. Downloads Providers
Terraform does not come with built-in code to talk to cloud platforms like AWS, Azure, Google Cloud, or Kubernetes. Instead, it relies on plugins called providers.
- `init` reads your configuration files, identifies which providers you need, and automatically downloads them from the Terraform Registry

```hcl
required_providers {
  google = {
    source = "hashicorp/google"
  }
}
```

### 3. Downloads Modules
If your configuration references external or reusable blocks of code called modules (whether from GitHub, a local path, or the public registry), `init` will find them, download them, and properly associate them with your directory

```hcl
module "network" {
  source = "./modules/network"
}
```

### 4. Creates Directory/Lock File
To store everything it just downloaded, the command creates a few hidden local files in your root folder

- `.terraform/` directory: A hidden cache folder where the downloaded provider plugins and modules are actually stored.
- `.terraform.lock.hcl` file: A dependency lock file. It records the exact versions of the provider plugins you downloaded so that if a teammate runs your code later, they are guaranteed to use the exact same versions. **Locks provider versions.**
> Lock Files Ensures consistent provider versions across developers and CI/CD pipelines.

---

## Common Commands

```bash
# basic Command
terraform init # basic

# Upgrade providers/modules:
terraform init -upgrade 

# Reconfigure backend:
terraform init -reconfigure

#Skip backend:
terraform init -backend=false
```

---

## When To Run

✅ New Project
✅ After Git Clone
✅ New Provider Added
✅ New Module Added
✅ Backend Changed

---

## The Core Terraform Workflow

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