# Expressions

## What are Expressions?

Expressions are pieces of Terraform code that produce a value.

```hcl
var.environment

local.bucket_name

1 + 2

"${var.environment}-logs"

Expression
      ↓
Produces Value
```
Every time Terraform evaluates something and gets a result, it is using an ***expression***.

---

## Why are Expressions Important?

Without expressions: Hardcoded.

```hcl
name = "dev-api-logs"
```

With expressions: Dynamic.

```hcl
name = "${var.environment}-${var.application}-logs"
```

Benefits:
- Reusable configurations
- Environment-specific deployments
- Less duplication
- More automation

---

## Variable Expressions

Reference variables.

```hcl
var.project_id

# Example
resource "google_storage_bucket" "logs" {
  name = var.bucket_name
}
```

---

## Local Expressions

Reference locals.

```hcl
local.prefix

# Example:
name = "${local.prefix}-logs"
```

---

## Resource Expressions

Reference resources.

```hcl
google_compute_instance.web.id

# Example:
output "vm_id" {
  value = google_compute_instance.web.id
}
```

---

## Arithmetic Expressions

Terraform supports basic math.

```hcl
1 + 2 # Addition

10 - 5 # Substraction
 
5 * 2 # Multiplication

10 / 2 # Division
```

---

## Comparison Expressions

Used for validation and conditions.

```hcl
# Equal
var.environment == "prod" 

# Not Equal
var.environment != "prod" 

# Greater Than
var.disk_size > 10

# Less Than
var.replicas < 5

var.count >= 3

var.count <= 3
```

---

## Logical Expressions

### AND

```hcl
var.enabled && var.production

Result:
true only if both are true
```

### OR

```hcl
var.enabled || var.production

# Result
true if either is true
```

### NOT

```hcl
!var.enabled

# Result:
opposite boolean value
```
---

## Conditional Expressions

Terraform supports ternary expressions.

```hcl
condition ? true_value : false_value

# Example
var.environment == "prod" ? "e2-standard-4" : "e2-medium"

prod -> e2-standard-4
others -> e2-medium

resource "google_compute_instance" "web" {

  machine_type =
    var.environment == "prod"
    ? "e2-standard-4"
    : "e2-medium"

}
```

---

## String Interpolation

Combine strings dynamically.

```hcl
"${var.environment}-logs"
```
For Multiple Variables

```hcl
"${var.environment}-${var.application}"
```
---

## `for` Expressions

Used to transform collections.

```hcl
[
  for item in collection :
  expression
]

# Example
[
  for zone in var.zones :
  upper(zone)
]
```

#### `for` Expression with Filtering

```hcl
[
  for item in collection :
  expression
  if condition
]

## Example:
[
  for n in [1,2,3,4,5] :
  n
  if n > 3
]
```

---

## Map Creation with for Expressions

Syntax
```hcl
{
  for zone in var.zones :
  zone => upper(zone)
}
```
Example:
```hcl
Input:
[
  "us-central1-a",
  "us-central1-b"
]

Output:
{
  "us-central1-a" = "US-CENTRAL1-A"
  "us-central1-b" = "US-CENTRAL1-B"
}
```

---

## Splat Expressions

Used to retrieve the same attribute from multiple resources.

```hcl
google_compute_instance.web[*].id

# Equivalent to:
[
  google_compute_instance.web[0].id,
  google_compute_instance.web[1].id,
  google_compute_instance.web[2].id
]
```
Commonly used with `count` & `for_each`