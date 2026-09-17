# terraform plan

`terraform plan` generates an execution plan showing what Terraform will do before making any changes.

```text
Current Infrastructure
          ↓
Compare
          ↓
Terraform Configuration
          ↓
Execution Plan
```
Terraform answers:
```text
What will be created?
What will be modified?
What will be destroyed?
```
without actually changing infrastructure.

`terraform plan` is read-only.
- Nothing is created, Nothing is modified, Nothing is destroyed.

---

## Why Use terraform plan?

Before applying changes, you want to know:

```text
Is Terraform creating resources?

Is Terraform updating resources?

Is Terraform deleting resources?

Are the changes expected?
```

`terraform plan` provides a preview.

---

## What Does terraform plan Do?

1. Read Configuration files `*.tf`
2. Terraform reads State `terraform.tfstate` or ***Remote State***
3. Query Provider: Terraform asks GCP: *What currently exists?*
4. Terraform compares: `Desired State vs Current State`
5. Generate Plan by giving output for Resouces to be **Added, Changed or Destoryed**

---

## Reading Plan Output

Terraform uses symbols.

1. `+`: Create resource.

```text
+ google_storage_bucket.logs
```
2. `~`: Modify resource.

```text
~ google_compute_instance.web
```
3. `-`: Delete resource.

```text
- google_storage_bucket.logs
```
4. `-/+` Replace resource. Meaning Destroy and then Recreate.
- Certain attributes require recreation.Like Changing immutable resource name

---

## Execution Plan Lifecycle

```text
Configuration
      ↓
State
      ↓
Provider
      ↓
Comparison
      ↓
Plan Output
```

---

### Saved Plans

Terraform allows plan files to be saved. 

```bash
terraform plan -out=tfplan

# tfplan is created.
```

##### Why Save Plans?
Common in CI/CD. Apply exactly what was reviewed

```bash
terraform plan -out=tfplan

terraform apply tfplan
```

---

### Variable and Variable Files Usage
Plan with variables:
```bash
terraform plan -var="environment=dev"
```

Using variable files:
```bash
terraform plan -var-file="dev.tfvars"
```
---

### Refresh Behavior & Detecting Drift
Terraform checks real infrastructure.
- Like Someone modified VM manually

Terraform detects drift. Plan shows differences. Terraform will update resource This helps detect infrastructure drift.

---

### Targeting Resources

Plan only specific objects.

```bash
terraform plan -target=google_storage_bucket.logs
```
Terraform focuses on: `logs bucket`

Useful for troubleshooting.
- Not recommended for routine use.

### Destroy Plan

Preview destruction.

```bash
terraform plan -destroy
```

### Refresh Only
Compare state with reality No infrastructure changes proposed. 
- Useful for drift detection.
```bash
terraform plan -refresh-only
```

### JSON Output
Generate machine-readable plan.

```bash
terraform show -json tfplan
```

Useful for:
- Automation
- Policy Checking
- Security Gates

---

## Common Flags

1. Save Plan `terraform plan -out=tfplan`
2. Variable `terraform plan -var="region=us-central1"`
3. Variable File `terraform plan -var-file="prod.tfvars"`
4. Destroy Preview `terraform plan -destroy`
5. Refresh Only `terraform plan -refresh-only`
6. Target Resource `terraform plan -target=google_storage_bucket.logs`

---

## Common Errors

1. Missing Variable
2. Authentication Failure
3. Invalid Resource Reference
4. Provider Issue: Provider not initialized.