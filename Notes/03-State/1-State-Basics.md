# State Basics

Terraform State is Terraform's memory.

It is how Terraform keeps track of the infrastructure it manages.

Terraform cannot effectively manage infrastructure without state.

State is the Source of Truth. Terraform relies heavily on state.

State tells Terraform:
- What Exists
- What Was Created
- What Must Change
- What Must Be Deleted

Without state Terraform loses context

### Why Do We Need State?

Suppose Terraform creates a VM. VM Exists in GCP

- How does Terraform know
- which VM it created?

> State File is where all the information about the exiting infrastructure managed my terraform resides.

Terraform stores:
- Resource IDs
- Resource Attributes
- Dependencies
- Metadata

Terraform stores information like:

```text
google_storage_bucket.logs

ID: app-logs
Location: US
Project: my-project
```
---

## State File

By default Terraform uses: `terraform.tfstate`

```text
project/

├── main.tf
├── variables.tf
├── outputs.tf
└── terraform.tfstate
```

## How Terraform Uses State
State is involved in almost every Terraform command.

```text
Read Configuration
        ↓
Read State
        ↓
Query Provider
        ↓
Compare
        ↓
Generate Plan
```

```text
Terraform Code -> Desired State

Terraform State -> Known State

Cloud Resources -> Actual State
```
Terraform continuously compares all three.

---

### Local State

Default behavior.

File: `terraform.tfstate`
```

Stored on local machine.

Example:

```text
Laptop
   ↓
terraform.tfstate
```

Suitable for:

```text
Learning
Labs
Personal Projects
```

Not ideal for teams.

---

# Remote State

State stored remotely.

Examples:

```text
GCS
AWS S3
Azure Storage
Terraform Cloud
```

Team workflow:

```text
Developer A
      ↓

      GCS State

      ↑

Developer B
```

Everyone uses the same state file.

---

# Example State Structure

Actual state file is JSON.

Very simplified example:

```json
{
  "resources": [
    {
      "type": "google_storage_bucket",
      "name": "logs"
    }
  ]
}
```

Terraform manages this automatically.

Never edit directly unless absolutely necessary.

---

# Why State Makes Terraform Fast

Without state:

```text
Terraform must discover
everything from scratch
```

With state:

```text
Terraform already knows
most resource information
```

Result:

```text
Faster Planning
Faster Applies
```

---

# State and Resource Addresses

Resource:

```hcl
resource "google_storage_bucket" "logs"
```

Address:

```text
google_storage_bucket.logs
```

State stores resources using these addresses.

---

## Viewing State

List resources:

```bash
terraform state list
```

Example:

```text
google_compute_instance.web
google_storage_bucket.logs
```

---

Show details:

```bash
terraform state show \
google_storage_bucket.logs
```

Displays:

```text
Attributes
IDs
Metadata
```

---

# State Lifecycle

```text
terraform apply
        ↓
Resource Created
        ↓
State Updated
        ↓
terraform plan
        ↓
State Read
        ↓
terraform destroy
        ↓
State Updated Again
```

---

# Common State Problems

## Lost State File

Delete:

```text
terraform.tfstate
```

Terraform loses tracking.

Possible issues:

```text
Duplicate Resources
Inaccurate Plans
Resource Drift
```

---

## Corrupted State

State becomes invalid.

Possible symptoms:

```text
Incorrect Plans
Missing Resources
Errors
```

Backups become important.

---

## Multiple Users Editing Same State

Developer A:

```bash
terraform apply
```

Developer B:

```bash
terraform apply
```

Using local state.

Result:

```text
State Conflicts
```

This is why teams use remote state.

---

# State and Drift

Configuration:

```text
VM = e2-medium
```

Someone changes VM manually:

```text
VM = e2-standard-2
```

Now:

```text
Configuration
      ≠
Infrastructure
```

Drift exists.

Terraform detects this during:

```bash
terraform plan
```

---

# State Commands

List resources:

```bash
terraform state list
```

---

Show resource:

```bash
terraform state show \
google_compute_instance.web
```

---

Move resource:

```bash
terraform state mv
```

---

Remove from state:

```bash
terraform state rm
```

---

# Best Practices

### ✅ Never Delete State Accidentally

State is critical.

---

### ✅ Store State Remotely for Teams

Example:

```text
GCS Backend
```

---

### ✅ Backup State

Always keep recovery options.

---

### ✅ Do Not Manually Edit State

Use Terraform commands whenever possible.

---

### ✅ Protect State Access

State may contain:

```text
Resource IDs
Project Information
Outputs
Sensitive Metadata
```

---

# Interview Questions

## What is Terraform State?

Terraform's record of the infrastructure it manages.

---

## Why is State Needed?

Terraform uses state to map Terraform resources to actual cloud resources.

---

## What is the default state file called?

```text
terraform.tfstate
```

---

## What happens if the state file is lost?

Terraform loses track of managed infrastructure and may attempt to recreate resources.

---

## What information is stored in state?

```text
Resource IDs
Attributes
Dependencies
Outputs
Metadata
```

---

## Difference Between Local and Remote State?

Local:

```text
Stored on local machine
```

Remote:

```text
Stored in shared backend
```

Examples:

```text
GCS
S3
Azure Storage
Terraform Cloud
```

---

## Why is Remote State Recommended?

Provides:

```text
Collaboration
Centralization
Consistency
Recovery
```

---

## Is State the Source of Truth?

Yes.

Terraform relies on state to understand infrastructure and calculate changes.

---

# Quick Revision

State:

```text
Terraform's Memory
```

Default File:

```text
terraform.tfstate
```

Stores:

```text
Resource IDs
Attributes
Outputs
Dependencies
Metadata
```

Used By:

```text
plan
apply
destroy
import
```

Types:

```text
Local State
Remote State
```

Common Commands:

```bash
terraform state list

terraform state show

terraform state mv

terraform state rm
```

Remember:

```text
Configuration
      ↓
Desired State

State
      ↓
Known State

Infrastructure
      ↓
Actual State
```

Interview Keywords:

```text
Source of Truth
Resource Mapping
State File
Remote Backend
Infrastructure Tracking
Drift Detection
```