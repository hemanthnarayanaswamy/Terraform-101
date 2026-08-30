# Resources

## What is a Resource?

A resource is the fundamental building block of Terraform. A resource represents an infrastructure object that Terraform manages. Infrastructure elements managed by Terraform are called `resources`. 

**Examples**:
- Virtual Machine
- Storage Bucket
- VPC Network
- Database
- Kubernetes Cluster
- Service Account

```text
Provider = Who Terraform talks to
Resource = What Terraform manages
```
---

## Resource Syntax

```hcl
resource "<TYPE>" "<NAME>" {
    ...
}

resource "google_storage_bucket" "logs" {
  name     = "app-logs-bucket"
  location = "US"
}
```

#### 1. Resource Type

The type identifies the infrastructure object.

```hcl
google_storage_bucket

google → Provider

storage_bucket → Resource Type

google_compute_instance
google_compute_network
google_sql_database_instance
google_container_cluster
google_service_account
```

#### 2. Resource Name
Here `Type = google_storage_bucket` and `Name = logs`

The name is only used inside Terraform. It does NOT create a bucket called *"logs"*.

```hcl
google_storage_bucket.logs
```

#### 3. Resource Attributes

Attributes configure the resource.

```hcl
resource "google_storage_bucket" "logs" {
  name          = "app-logs"
  location      = "US"
  storage_class = "STANDARD"
}

## Attributes:
name
location
storage_class
```

#### 4. Resource Lifecycle

Terraform manages resources through a lifecycle.

```text
Write Code
     |
     V
terraform plan
     |
     V
terraform apply
     |
     V
Resource Created

**** Later ****

Code Change
     |
     V
terraform plan
     |
     V
terraform apply
     |
     V
Resource Updated

**** Or ****

terraform destroy #Resource removed.
```

#### 5. Resource References

Resources can reference other resources.

Example:

```hcl
resource "google_compute_network" "main" {
  name = "main-vpc"
}

## Use elsewhere:

network = google_compute_network.main.id

## Syntax:

<resource_type>.<resource_name>.<attribute>

google_compute_network.main.id
```

##### Example: ***VPC + VM***

Create VPC:
```hcl
resource "google_compute_network" "main" {
  name = "main-vpc"
}
```

Create VM:
```hcl
resource "google_compute_instance" "web" {
  name         = "web-server"
  machine_type = "e2-medium"

  network_interface {
    network = google_compute_network.main.id
  }
}
```
Terraform automatically understands: ***VPC must exist first**. This creates an implicit dependency.

---

## Resource Dependencies
Terraform doesn’t just create resources — it builds a dependency graph to determine the correct order of deployment. Terraform automatically maps these relationships using a ***Directed Acyclic Graph (`DAG`)***

#### 1. Implicit Dependency
Terraform automatically understands the dependency when one resource references another resource’s attribute.

```ini
network = google_compute_network.main.id

## Terraform knows:
Network
   ↓
VM
```
- Cleaner code
- Less configuration
- Terraform manages the order automatically

#### 2. Explicit Dependency - `depends_on`
Used when a dependency exists but T𝗲𝗿𝗿𝗮𝗳𝗼𝗿𝗺 𝗰𝗮𝗻𝗻𝗼𝘁 𝗱𝗲𝘁𝗲𝗰𝘁 𝗶𝘁 𝘁𝗵𝗿𝗼𝘂𝗴𝗵 𝗮 𝗱𝗶𝗿𝗲𝗰𝘁 𝗿𝗲𝗳𝗲𝗿𝗲𝗻𝗰𝗲. 
- Use only when Terraform cannot determine dependency automatically.

- Handles hidden dependencies
- Ensures correct deployment order
- Helps avoid race conditions

```hcl
resource "google_compute_instance" "web" {
  depends_on = [
    google_compute_network.main
  ]

  ...
}
```
Avoid Overusing `depends_on`: Relying heavily on explicit dependencies degrades Terraform’s performance. Because explicit targets lack granular information, Terraform takes a highly conservative approach, which often forces serial execution and unnecessarily prolongs terraform apply windows.

---

## Meta Arguments

Meta arguments are special arguments supported by many Terraform resources.

They control how Terraform creates, updates, or manages resources.

```bash
count
for_each
depends_on
provider
lifecycle
```

#### 1. `count`

Used to create multiple copies of a resource.

```hcl
resource "google_storage_bucket" "bucket" {
  count = 3

  name     = "bucket-${count.index}"
  location = "US"
}

## Creates:
bucket-0
bucket-1
bucket-2

## Access specific instances:

google_storage_bucket.bucket[0]
```

Use `count` when:
- Resources are nearly identical
- Number of resources is known

#### 2. `for_each`

Creates resources from a collection.

```hcl
resource "google_storage_bucket" "bucket" {
  for_each = toset(["logs", "backup", "archive"])
  name     = each.value
  location = "US"
}

## Creates:
- logs
- backup
- archive

## Reference:

google_storage_bucket.bucket["logs"]
```

Use `for_each` when:
- Resources have unique identities
- Resources may be added/removed later

**Preferred over count in most real-world projects.**

#### 3. `depends_on`

Creates explicit dependencies.

```hcl
resource "google_storage_bucket" "logs" {
  depends_on = [
    google_project_service.storage_api
  ]

  name = "logs-bucket"
}

## Terraform creates:

storage_api
      ↓
logs_bucket
```
Use only when Terraform cannot infer dependencies automatically.

#### 4. `provider`

Specifies which provider configuration to use.

```hcl
provider "google" {
  project = "dev-project"
}

provider "google" {
  alias   = "prod"
  project = "prod-project"
}

resource "google_storage_bucket" "logs" {
  provider = google.prod
  name = "prod-logs"
}
```

Useful for:
- Multiple projects
- Multiple regions
- Shared infrastructure


#### 5. `lifecycle`

Controls resource lifecycle behavior.

```hcl
resource "google_storage_bucket" "logs" {

  lifecycle {
    prevent_destroy = true
  }

}

## Includes:
- prevent_destroy
- create_before_destroy
- ignore_changes
- replace_triggered_by
```

#### 6. Lifecycle Rules

##### A. `prevent_destroy`
Prevents accidental deletion.

```hcl
lifecycle {
  prevent_destroy = true
}

# Useful for:
- Production Databases
- Critical Buckets
- Shared Infrastructure
```
If someone runs: `terraform destroy`. Terraform throws an error.


##### B. `create_before_destroy`
Creates replacement first.

```hcl
lifecycle {
  create_before_destroy = true
}

## Default behavior:
Destroy
  ↓
Create

## With create_before_destroy:
Create
  ↓
Destroy
```
Useful for minimizing downtime.

##### C. `ignore_changes`

Ignore modifications on selected fields.

```hcl
lifecycle {
  ignore_changes = [
    labels
  ]
}

## Terraform ignores:
label changes
```
while managing everything else.

Useful when:
- Another team updates labels
- External systems modify metadata

---

##### D. `replace_triggered_by`

Force replacement when another object changes.

```hcl
lifecycle {
  replace_triggered_by = [
    google_compute_disk.data
  ]
}

### If disk changes:
terraform replaces resource
```

---

## Resource Graph
Terraform creates a dependency graph.

```text
VPC
 ↓
Subnet
 ↓
VM
 ↓
Application
```

Terraform uses this graph to:
- Determine creation order
- Determine destruction order
- Enable parallel execution

---

## Resource State

Terraform keeps track of resources in: `terraform.tfstate`

State contains:
```text
Resource IDs
Attributes
Metadata
Dependencies
```

Without state: Terraform loses tracking ability

---

## Resource Drift

Drift occurs when infrastructure changes outside Terraform.

Terraform:
```hcl
machine_type = "e2-medium"
```

Someone changes VM manually: in Google Cloud Console.
```text
e2-standard-4
```

Now: `Terraform Stat ≠ Real Infrastructure` 

This is called `drift`. 

Detect drift: `terraform plan` compares:
```text
Configuration
      ↓
    State
      ↓
Real Infrastructure
```
and reports differences.

---

## Resource Replacement

Some changes require replacement.

```hcl
name = "vm-1"

# Change:

name = "vm-2"
```
Terraform may show: `-/+ resource will be replaced`

Meaning:
```ini
Destroy old resource
        +
Create new resource
```

Some attributes are immutable and cannot be modified in-place.

Terraform marks these attributes as: `ForceNew`

Examples often requiring replacement:
- Resource name changes
- Certain network settings
- Some machine image changes
- Certain database configuration changes

---

## Tainted Resources

Sometimes a resource is unhealthy or partially created.

Older Terraform versions used:
```bash
terraform taint google_compute_instance.web

# Mark resource for recreation
# During Next apply the resource will 

Destroy
   ↓
Recreate
```

Modern Terraform prefers:
```bash
terraform apply -replace=google_compute_instance.web
# This is more explicit and safer.
```
---

## Import Existing Resources

Terraform can start managing infrastructure that already exists.

Terraform configuration:
```hcl
resource "google_storage_bucket" "logs" {
  name = "my-existing-bucket"
}
```

Import: `terraform import google_storage_bucket.logs my-existing-bucket`

```text
Terraform State
       ↕
Existing Bucket
```
Terraform now tracks the bucket.

---

## Resource State Relationship

Terraform uses state to map resources.

```hcl
resource "google_compute_instance" "web"

# State stores:

google_compute_instance.web
          ↓
Actual VM ID
```

Without state:

```text
Terraform does not know
what it created previously
```

