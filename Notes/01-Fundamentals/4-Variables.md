# Variables

## What is a Variable?

Variables allow Terraform configurations to become reusable and configurable.

Instead of hardcoding values:

```hcl
machine_type = "e2-medium"

## we can use:

machine_type = var.machine_type
```

and supply different values for different environments. `Variables = Inputs to Terraform`

---

## Why Use Variables?

Without variables:

```hcl
resource "google_compute_instance" "web" {
  machine_type = "e2-medium"
}

# With variables:
machine_type = "e2-standard-2"
machine_type = var.machine_type
```

Benefits:
- Reusable code
- Environment flexibility
- Cleaner configurations
- Easier maintenance

---

## Variable Declaration

Syntax:

```hcl
variable "<NAME>" {
}

variable "machine_type" {
}

## Declare Variables
variable "machine_type" {
  type = string
}

## Use Variables
resource "google_compute_instance" "web" {
  machine_type = var.machine_type
}
```

Provide value:

```bash
terraform apply -var="machine_type=e2-medium"
```
---

## Referencing Variables

Syntax:
```hcl
var.<variable_name>

var.machine_type
var.region
var.project_id
```
---

## Variable Types

Terraform supports multiple data types.

#### 1. String
A sequence of Unicode characters representing text. Must be enclosed in double quotes.
```hcl
variable "project_id" {
  type = string
}
```

#### 2. Number
Represents both *integers* (like 15) and *floating-point* fractional values (like 6.28). No quotes are used.
```hcl
variable "disk_size" {
  type = number
}
```

#### 3. Boolean
A logical boolean value. Accepts only literal `true / false` without quotes.
```hcl
variable "enable_backup" {
  type = bool
}
```
***Collection*** types group multiple values together. Crucially, all elements inside a collection must be of the same data type.

#### 4. `list(<TYPE>)`
An ordered sequence of values indexed by consecutive integers starting at zero.

```hcl
variable "zones" {
  type = list(string)
}
# ["us-central1-a", "us-central1-b"]
# To Access 
var.zones[0]
```

#### 5. `map(<TYPE>)`
A collection of key-value pairs where string labels identify the values.
```hcl
variable "labels" {
  type = map(string)
}

{ env  = "dev" 
  team = "platform"
}
# To Access:
var.labels["env"]
```
#### 6. `set(<TYPE>)`
An unordered collection of unique values. Duplicates are automatically removed.

```hcl
variable "security_groups" {
  type    = set(string)
  default = ["sg-1", "sg-2"]
}
```
***Structural types*** allow you to group values of different data types into a single complex schema.

#### 7. `object({...})`
A complex type that defines a custom mapping of explicit attribute names to specific value types.
```hcl
variable "vm_config" {
  type = object({
    machine_type = string
    disk_size    = number
  })
}

{
  machine_type = "e2-medium"
  disk_size    = 100
}
# Access:
var.vm_config.machine_type
```

#### 8. `tuple([...])`
A fixed-length, ordered sequence where each distinct element position has its own designated type.

```hcl
variable "network_settings" {
  type    = tuple([string, number, bool])
  default = ["10.0.0.0/16", 80, true]
}
```
#### 9. DYNAMIC TYPING - `any`
If you need a variable to accept any type dynamically without checking structural constraints, you can use the special keyword `any` as a placeholder. 
- Terraform will infer the exact type at runtime based on the value passed.

```hcl
variable "passthrough_data" {
  type    = any
  default = { text = "hello", code = 200 }
}
```
---

## Default Values

A variable may have a default value.

```hcl
variable "region" {
  type    = string
  default = "northamerica-northeast1"
}
```
For `var.region`, Terraform automatically uses `northamerica-northeast1` if no value is supplied.

---

## Required Variables

No default value:

```hcl
variable "project_id" {
  type = string
}
```

Terraform requires input.

Running `terraform apply` prompts you to Enter the missing information. 

```text
var.project_id
Enter a value:
```
---

## Description
Description helps document variables.

```hcl
variable "project_id" {
  type        = string
  description = "GCP Project ID"
}
```

---

## Validation

Terraform can validate inputs.

```hcl
variable "disk_size" {
  type = number

  validation {
    condition     = var.disk_size > 10
    error_message = "Disk size must be greater than 10 GB."
  }
}
```

---

## Nullable

By default: ***null allowed***

Can disable:
```hcl
variable "project_id" {
  type     = string
  nullable = false
}
```
Terraform ensures value exists.

---

## Sensitive Variables
Hide sensitive values from output.

```hcl
variable "db_password" {
  type      = string
  sensitive = true
}
```

Useful for:
- Passwords
- Secrets
- API Keys

---

## Variable Files

Most projects use: `terraform.tfvars`

Example:
```hcl
project_id   = "my-project"
region       = "us-central1"
machine_type = "e2-medium"
```

`terraform apply` Terraform automatically loads: `terraform.tfvars`

---
## `terraform.tfvars`

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
---

## Custom Variable Files
We can define the `.tfvars` with different names but that should be exlicitly mentioned and loaded during the `terraform apply`
```text
dev.tfvars
qa.tfvars
prod.tfvars
```

```bash
terraform apply -var-file="dev.tfvars"

terraform apply -var-file="prod.tfvars"
```
Useful for different environments.

---

## Environment Variables

Terraform can read variables from environment variables. But it needs to follow the exact format. `TF_VAR_<variable_name>`

```bash
export TF_VAR_project_id=my-project
```

Terraform automatically loads:
```hcl
var.project_id
```

---

## Variable Precedence

![img](https://www.devopsschool.com/blog/wp-content/uploads/2023/09/image-456.png)

```ini
1. Highest Priority: Command Line
terraform apply -var="region=us-east1"

2. terraform.tfvars

3. Environment Variables

4. Default Values
```
---

## Best Practices

1. Always Define Types
2. Add Descriptions
3. Use Defaults Carefully
4. Mark Secrets Sensitive
5. Use tfvars for Environments

---

## Common Errors

1. Missing Required Variable
2. Wrong Type: Invalid value for variable
3. Invalid Validation Rule

---