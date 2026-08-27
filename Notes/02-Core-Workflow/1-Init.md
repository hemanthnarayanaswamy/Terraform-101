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