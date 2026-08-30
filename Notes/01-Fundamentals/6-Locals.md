# Locals

## What are Locals?

Locals are named values computed inside Terraform. Calculated internally. ***Derived Values***

```text
Variables = Inputs
Locals = Calculated Values
Outputs = Results
```
Locals help avoid repeating the same expressions throughout your configuration.

---

## Why Use Locals?

Without locals:
```hcl
resource "google_storage_bucket" "logs" {
  name = "${var.environment}-logs"
}

resource "google_storage_bucket" "backup" {
  name = "${var.environment}-backup"
}

resource "google_storage_bucket" "archive" {
  name = "${var.environment}-archive"
}
```

With locals:
```hcl
locals {
  env = var.environment
}

name = "${local.env}-logs"
name = "${local.env}-backup"
name = "${local.env}-archive"
```

Benefits:
- Less repetition
- Better readability
- Easier maintenance
- Centralized calculations

---

## Local Syntax

```hcl
# SYNTAX
locals {
  name = value
}

# EXAMPLE
locals {
  environment = "dev"
  region      = "us-central1"
  owner       = "platform-team"
}

# REFERENCE
local.<name>

local.environment
local.bucket_name
local.project_prefix
```

---

## Computed Values

Locals are often used to calculate values. 
- Depending on input variables.

```hcl
locals {
  bucket_name = "${var.environment}-logs"
}

resource "google_storage_bucket" "logs" {
  name = local.bucket_name
}

# RESULT
dev-logs
prod-logs
```
---

## Using Maps in Locals

```hcl
locals {
  machine_sizes = {
    dev  = "e2-medium"
    test = "e2-standard-2"
    prod = "e2-standard-4"
  }

}

# Usage:
local.machine_sizes[var.environment]

# Result:
dev  -> e2-medium
prod -> e2-standard-4
```

---

## Using Lists in Locals

```hcl
locals {
  zones = [
    "us-central1-a",
    "us-central1-b",
    "us-central1-c"
  ]
}

# Access:
local.zones[0]

# Result:
us-central1-a
```

---

## Using Objects in Locals

```hcl
locals {

  vm_config = {
    machine_type = "e2-medium"
    disk_size    = 50
  }

}

# Usage:
local.vm_config.machine_type
```

---

## Example: Environment-Based Configuration

```hcl
# Variable:

variable "environment" {
  type = string
  default = 'dev'
}

# Locals:

locals {

  machine_types = {
    dev  = "e2-medium"
    prod = "e2-standard-4"
  }

}

# Resource:

resource "google_compute_instance" "web" {

  machine_type =
    local.machine_types[var.environment]

}


# Result:
dev  -> e2-medium
prod -> e2-standard-4
```

---

## Evaluation Order

Terraform generally works like this:

```text
Variable → Local → Resource → Output
```

---

## Organizing Locals

Most projects keep locals in:

```text
locals.tf
```

Project Structure:

```text
terraform/

├── providers.tf
├── variables.tf
├── locals.tf
├── main.tf
├── outputs.tf
└── terraform.tfvars
```

---

## Best Practices

#### 1. Use Locals for Repeated Values

```hcl
# Bad
"${var.environment}-logs"
"${var.environment}-backup"
"${var.environment}-archive"

# Good
local.prefix
```

#### 2. Use Locals for Naming Standards

```hcl
locals {
  prefix = "${var.environment}-${var.application}"
}
```

#### 3. Keep Business Logic in Locals

```hcl
locals {

  machine_types = {
    dev  = "e2-medium"
    prod = "e2-standard-4"
  }

}
```

#### 4. Store Locals in `locals.tf`

Improves organization.

---

## Common Mistakes

1. Treating Locals Like Variables
2. Duplicating Logic
3. Using Outputs Instead of Locals If value is used only within Terraform use `local` not `output`