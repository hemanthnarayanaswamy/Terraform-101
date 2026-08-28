# Functions

## What are Functions?

Terraform functions are built-in features that help with simple management and manipulation of data within your Terraform configurations, enabling you to perform data transformations and ensure smooth infrastructure provisioning. 

Terraform's built-in functions include a variety of utilities to transform and combine values such as string formatting, arithmetic calculations, and working with lists and maps directly in your code.

---

## Why Use Functions?

Terraform functions are important for tasks such as variable interpolation, generating resource names, and applying conditional logic:

- String manipulation
- List processing
- Map processing
- Data transformation
- Validation
- Dynamic configuration



## Function Syntax

```hcl
function_name(argument1, argument2, ...)
l
upper("terraform")
length(var.zones)
```

---

## Common Terraform Function Categories

<table class="table__component"><thead class="table__head"><tr class="table__row"><th class="table__header" width="20%">Category </th><th width="30%" class="table__header">Description </th><th class="table__header">Examples</th></tr></thead><tbody class="table__body"><tr class="table__row"><td class="table__cell cc-feature">String </td><td class="table__cell">Manipulate and transform strings</td><td class="table__cell"><span class="code">join(separator, list)</span>, <span class="code">split(separator, string)</span>, <span class="code">replace(string, search, replace)</span>, <span class="code">trimspace(string)</span> etc.</td></tr><tr class="table__row"><td class="table__cell cc-feature">Numeric </td><td class="table__cell">Perform arithmetic operations</td><td class="table__cell"><span class="code">abs(number)</span>, <span class="code">ceil(number), floor(number)</span> etc.</td></tr><tr class="table__row"><td class="table__cell cc-feature">Collection</td><td class="table__cell">Work with lists, maps, and sets</td><td class="table__cell"><span class="code">length(list or map)</span>, <span class="code">element(list, index)</span>, <span class="code">flatten(list)</span>, <span class="code">merge(map1, map2, ...)</span> etc. </td></tr><tr class="table__row"><td class="table__cell cc-feature">Date and Time </td><td class="table__cell">Work with date and time values</td><td class="table__cell"><span class="code">timestamp()</span>, <span class="code">timeadd(timestamp, duration)</span>, <span class="code">formatdate(format, timestamp)</span>, <span class="code">uuid()</span> etc.</td></tr><tr class="table__row"><td class="table__cell cc-feature">Encoding </td><td class="table__cell">Encode and decode values, and transform data formats</td><td class="table__cell"><span class="code">base64encode(string)</span>, <span class="code">base64decode(string)</span>, <span class="code">jsondecode(string)</span> etc. </td></tr><tr class="table__row"><td class="table__cell cc-feature">Type Conversion </td><td class="table__cell">Convert between different types</td><td class="table__cell"><span class="code">tostring(value)</span>, <span class="code">tonumber(value)</span>, <span class="code">toset(value) etc.</span></td></tr><tr class="table__row"><td class="table__cell cc-feature">Filesystem</td><td class="table__cell">Read files from the filesystem</td><td class="table__cell"><span class="code">file(path)</span>, <span class="code">filebase64(path)</span>, <span class="code">dirname(path)</span> etc.</td></tr><tr class="table__row"><td class="table__cell cc-feature">IP Network </td><td class="table__cell">Work with IP addresses and networks</td><td class="table__cell"><span class="code">cidrnetmask(prefix)</span>, <span class="code">cidrrange(prefix)</span> etc.</td></tr></tbody></table>

---

# String Functions

This category focuses on string-related functions, making it easier to construct and manipulate strings within your code. This can be particularly useful for naming resources, generating tags, and formatting output values.

#### 1. `upper()`/`lower()`
Converts text to uppercase and Converts text to lowercase.

```hcl
upper("terraform") - TERRAFORM

lower("TERRAFORM") - terraform
```
#### 2. `title()`
Capitalizes each word.

```hcl
title("google cloud platform")

Google Cloud Platform
```
#### 3. `trim()`
Removes characters from both ends.

```hcl
trim("--terraform--", "-")

terraform
```
#### 4. `replace(string, substring-tobe-replaced, replacement)`
Replace text.

```hcl
replace("dev-api", "dev", "prod")

prod-api
```

#### 5. `split(separator, string)`
Break string into list.

```hcl
split("-", "dev-api")

["dev", "api"]
```

#### 6. `join(separator, list)`
Combine list into string.

```hcl
join("-", ["dev", "api"])

dev-api
```

#### 7. `substr(string, start_idx, end_idx)`
Extract part of a string. Indexing works similar to python.

```hcl
substr("terraform", 0, 4)

terr
```
---
---

# Numeric Functions
Numeric-related functions help execute calculations on numeric values, such as rounding numbers or getting absolute values.

1. `max()`: Largest value.
```hcl
max(10, 20, 30)
30
```
2. `min()`: Smallest value.
```hcl
min(10, 20, 30)
10
```
3. `abs()`: Absolute value.
```hcl
abs(-10)
10
```
4. `ceil()`: Round up.
```hcl
ceil(4.1)
5
```
5. `floor()`: Round down.
```hcl
floor(4.9)
4
```
---

# Collection Functions

This category focuses on handling and manipulating lists and maps, making working with complex data structures in your configurations easier. These functions are useful for counting elements, retrieving specific items, flattening nested lists, and merging maps.

## length()

Returns number of elements.

```hcl
length(["a","b","c"])
```

Result:

```text
3
```

---

## contains()

Checks if collection contains value.

```hcl
contains(
  ["dev","test","prod"],
  "prod"
)
```

Result:

```text
true
```

---

## distinct()

Removes duplicates.

```hcl
distinct(
  ["a","a","b","c"]
)
```

Result:

```hcl
[
  "a",
  "b",
  "c"
]
```

---

## sort()

Sort list.

```hcl
sort(
  ["c","a","b"]
)
```

Result:

```hcl
[
  "a",
  "b",
  "c"
]
```

---

## reverse()

Reverse list.

```hcl
reverse(
  ["a","b","c"]
)
```

Result:

```hcl
[
  "c",
  "b",
  "a"
]
```

---

## element()

Retrieve item by index.

```hcl
element(
  ["a","b","c"],
  1
)
```

Result:

```text
b
```

---

## keys()

Get map keys.

```hcl
keys({
  env = "dev"
  app = "api"
})
```

Result:

```hcl
[
  "app",
  "env"
]
```

---

## values()

Get map values.

```hcl
values({
  env = "dev"
  app = "api"
})
```

Result:

```hcl
[
  "api",
  "dev"
]
```



---

# Type Conversion Functions

## tostring()

Convert to string.

```hcl
tostring(100)
```

Result:

```text
"100"
```

---

## tonumber()

Convert to number.

```hcl
tonumber("100")
```

Result:

```text
100
```

---

## tolist()

Convert to list.

```hcl
tolist(["a","b"])
```

Result:

```hcl
[
  "a",
  "b"
]
```

---

## tomap()

Convert to map.

```hcl
tomap({
  env = "dev"
})
```

---

## toset()

Convert list to set.

```hcl
toset([
  "a",
  "a",
  "b"
])
```

Result:

```hcl
[
  "a",
  "b"
]
```

Unique values only.

---

# File Functions

## file()

Read file contents.

```hcl
file("script.sh")
```

Returns file content.

---

## fileexists()

Check if file exists.

```hcl
fileexists("script.sh")
```

Result:

```text
true
```

---

# Encoding Functions

## jsonencode()

Convert Terraform object to JSON.

```hcl
jsonencode({
  env = "dev"
})
```

Result:

```json
{"env":"dev"}
```

---

## jsondecode()

Convert JSON to Terraform object.

```hcl
jsondecode("{\"env\":\"dev\"}")
```

Result:

```hcl
{
  env = "dev"
}
```

---

## base64encode()

```hcl
base64encode("terraform")
```

---

## base64decode()

```hcl
base64decode("dGVycmFmb3Jt")
```

---

# Date & Time Functions

## timestamp()

Current UTC timestamp.

```hcl
timestamp()
```

Example:

```text
2026-08-28T17:00:00Z
```

---

## formatdate()

Format date.

```hcl
formatdate(
  "YYYY-MM-DD",
  timestamp()
)
```

Result:

```text
2026-08-28
```

---

# Network Functions

Terraform provides built-in networking functions that are commonly used when working with:

- VPCs
- Subnets
- IP Planning
- Multi-region deployments
- GCP Networking
- AWS Networking
- Azure Networking

The most important networking functions are:

```text
cidrsubnet()
cidrhost()
cidrnetmask()
```

---

## cidrsubnet()

Creates a subnet from an existing network.

Syntax:

```hcl
cidrsubnet(prefix, newbits, netnum)
```

Parameters:

```text
prefix  -> Parent CIDR block
newbits -> Number of additional subnet bits
netnum  -> Subnet number
```

---

### Example

```hcl
cidrsubnet(
  "10.0.0.0/16",
  8,
  1
)
```

Result:

```text
10.0.1.0/24
```

---

### How it Works

Parent Network:

```text
10.0.0.0/16
```

Adding:

```text
8 bits
```

Creates:

```text
/24 subnets
```

Available subnets:

```text
10.0.0.0/24
10.0.1.0/24
10.0.2.0/24
10.0.3.0/24
...
```

Using:

```text
netnum = 1
```

Result:

```text
10.0.1.0/24
```

---

### More Examples

#### First Subnet

```hcl
cidrsubnet(
  "10.0.0.0/16",
  8,
  0
)
```

Result:

```text
10.0.0.0/24
```

---

#### Second Subnet

```hcl
cidrsubnet(
  "10.0.0.0/16",
  8,
  1
)
```

Result:

```text
10.0.1.0/24
```

---

#### Third Subnet

```hcl
cidrsubnet(
  "10.0.0.0/16",
  8,
  2
)
```

Result:

```text
10.0.2.0/24
```

---

## Real GCP Example

VPC:

```text
10.0.0.0/16
```

Subnets:

```hcl
locals {

  subnet_a = cidrsubnet(
    "10.0.0.0/16",
    8,
    0
  )

  subnet_b = cidrsubnet(
    "10.0.0.0/16",
    8,
    1
  )

}
```

Results:

```text
10.0.0.0/24
10.0.1.0/24
```

Useful when creating VPCs dynamically.

---

## cidrhost()

Returns a specific host IP within a network.

Syntax:

```hcl
cidrhost(prefix, hostnum)
```

Parameters:

```text
prefix  -> CIDR block
hostnum -> Host number
```

---

### Example

```hcl
cidrhost(
  "10.0.1.0/24",
  10
)
```

Result:

```text
10.0.1.10
```

---

### More Examples

#### First Host

```hcl
cidrhost(
  "10.0.1.0/24",
  1
)
```

Result:

```text
10.0.1.1
```

---

#### Fifth Host

```hcl
cidrhost(
  "10.0.1.0/24",
  5
)
```

Result:

```text
10.0.1.5
```

---

#### Tenth Host

```hcl
cidrhost(
  "10.0.1.0/24",
  10
)
```

Result:

```text
10.0.1.10
```

---

## Real Example

```hcl
locals {

  subnet = cidrsubnet(
    "10.0.0.0/16",
    8,
    0
  )

  gateway = cidrhost(
    local.subnet,
    1
  )

}
```

Results:

```text
Subnet  = 10.0.0.0/24
Gateway = 10.0.0.1
```

---

## cidrnetmask()

Returns the subnet mask from a CIDR block.

Example:

```hcl
cidrnetmask("10.0.0.0/24")
```

Result:

```text
255.255.255.0
```

---

### More Examples

```hcl
cidrnetmask("10.0.0.0/16")
```

Result:

```text
255.255.0.0
```

---

```hcl
cidrnetmask("10.0.0.0/8")
```

Result:

```text
255.0.0.0
```

---

# Functions + Locals

Very common pattern:

```hcl
locals {

  vpc_cidr = "10.0.0.0/16"

  app_subnet = cidrsubnet(
    local.vpc_cidr,
    8,
    0
  )

  db_subnet = cidrsubnet(
    local.vpc_cidr,
    8,
    1
  )

}
```

Results:

```text
app_subnet -> 10.0.0.0/24
db_subnet  -> 10.0.1.0/24
```

---

# GCP Example

```hcl
resource "google_compute_subnetwork" "app" {

  name = "app-subnet"

  ip_cidr_range = cidrsubnet(
    "10.0.0.0/16",
    8,
    0
  )

  region = var.region

}
```

Terraform automatically calculates:

```text
10.0.0.0/24
```

---

# Best Practices

### ✅ Define Network Once

```hcl
locals {
  vpc_cidr = "10.0.0.0/16"
}
```

---

### ✅ Generate Subnets Dynamically

```hcl
cidrsubnet()
```

instead of hardcoding subnets.

---

### ✅ Keep Address Planning Predictable

Good:

```text
10.0.0.0/24 App
10.0.1.0/24 Database
10.0.2.0/24 Shared
```

Bad:

```text
Random CIDR allocations
```

---

# Interview Questions

### What does cidrsubnet() do?

Creates smaller subnet CIDR blocks from a larger network CIDR block.

---

### What does cidrhost() do?

Returns a specific host IP address within a CIDR block.

---

### What does cidrnetmask() do?

Converts CIDR notation into a subnet mask.

---

### Why is cidrsubnet() useful?

Because it allows Terraform to generate subnet ranges dynamically instead of hardcoding them.

---

# Quick Revision

Network Functions:

```text
cidrsubnet()
cidrhost()
cidrnetmask()
```

Most Important:

```hcl
cidrsubnet(
  "10.0.0.0/16",
  8,
  1
)
```

Result:

```text
10.0.1.0/24
```

Use Cases:

```text
VPC Design
Subnet Allocation
GKE Networking
Multi-Environment Networks
Infrastructure Automation
```
# Filesystem Functions

Filesystem functions work with files and paths on the machine where Terraform runs.

Useful for:

- Reading startup scripts
- Loading JSON policies
- Reading configuration files
- Loading templates

---

## file()

Reads the contents of a file.

Example:

```hcl
file("startup.sh")
```

startup.sh:

```bash
#!/bin/bash
echo "Hello World"
```

Result:

```text
Entire file contents returned as a string
```

---

## fileexists()

Checks whether a file exists.

Example:

```hcl
fileexists("startup.sh")
```

Result:

```text
true
```

or

```text
false
```

---

## fileset()

Returns files matching a pattern.

Example:

```hcl
fileset(".", "*.tf")
```

Suppose:

```text
main.tf
variables.tf
outputs.tf
README.md
```

Result:

```hcl
[
  "main.tf",
  "outputs.tf",
  "variables.tf"
]
```

---

## dirname()

Returns parent directory.

Example:

```hcl
dirname("/home/hemanth/main.tf")
```

Result:

```text
/home/hemanth
```

---

## basename()

Returns final part of path.

Example:

```hcl
basename("/home/hemanth/main.tf")
```

Result:

```text
main.tf
```

---

## path.module

Path of current module.

Example:

```hcl
path.module
```

Result:

```text
/modules/network
```

Commonly used with:

```hcl
file("${path.module}/script.sh")
```

---

## path.root

Path of root module.

Example:

```hcl
path.root
```

---

## path.cwd

Current working directory.

Example:

```hcl
path.cwd
```

---

## Real Example

Startup Script:

```hcl
resource "google_compute_instance" "web" {

  metadata_startup_script =
    file("${path.module}/startup.sh")

}
```

Terraform loads:

```text
startup.sh
```

and injects it into the VM.

---

# Date & Time Functions

Terraform provides functions for working with timestamps and dates.

Useful for:

- Naming resources
- Generating unique values
- Expiration calculations
- Logging metadata

---

## timestamp()

Returns the current UTC timestamp.

Example:

```hcl
timestamp()
```

Result:

```text
2026-08-28T17:00:00Z
```

Format:

```text
RFC3339
```

---

## formatdate()

Formats a timestamp.

Syntax:

```hcl
formatdate(format, timestamp)
```

Example:

```hcl
formatdate(
  "YYYY-MM-DD",
  timestamp()
)
```

Result:

```text
2026-08-28
```

---

## Common Format Tokens

Year:

```text
YYYY
```

Month:

```text
MM
```

Day:

```text
DD
```

Hour:

```text
hh
```

Minute:

```text
mm
```

Second:

```text
ss
```

---

## Example

```hcl
formatdate(
  "YYYY-MM-DD hh:mm:ss",
  timestamp()
)
```

Result:

```text
2026-08-28 17:00:00
```

---

## timeadd()

Adds time duration.

Syntax:

```hcl
timeadd(timestamp, duration)
```

Example:

```hcl
timeadd(
  timestamp(),
  "24h"
)
```

Result:

```text
Tomorrow's timestamp
```

---

### More Examples

Add 1 Hour:

```hcl
timeadd(
  timestamp(),
  "1h"
)
```

---

Add 30 Minutes:

```hcl
timeadd(
  timestamp(),
  "30m"
)
```

---

Add 7 Days:

```hcl
timeadd(
  timestamp(),
  "168h"
)
```

---

## Example: Expiration Date

```hcl
locals {

  expires_at =
    timeadd(
      timestamp(),
      "720h"
    )

}
```

Result:

```text
30 days from 