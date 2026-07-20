# Terraform Language (HCL) — Deep-Dive Coding Workbook

> Companion to the roadmap. This document is **language-first and code-heavy**. Learn each construct, then immediately write HCL, predict outputs, debug broken snippets, and build real scenarios. Solutions are hidden in `<details>` blocks — try first, then expand.

**How to use:** Type every snippet into `.tf` files in a sandbox and run `terraform console`, `terraform validate`, `terraform plan`. The `terraform console` REPL is your best friend for the language — most expression exercises here can be tested there in seconds.

```bash
# Your two most-used commands while learning the language:
terraform console        # interactive REPL to test expressions
terraform validate       # checks syntax + types without hitting AWS
```

---

# PART A — The Language, Construct by Construct

Each section: **what it is → syntax → gotchas → drills → self-check.**

---

## A1. File & Block Structure

Terraform reads **all `.tf` files in a directory** and merges them (order doesn't matter). A block has a **type**, zero or more **labels**, and a **body** of arguments and nested blocks.

```hcl
block_type "label_one" "label_two" {
  argument = "value"
  nested_block {
    other = 1
  }
}
```

The top-level block types you'll use:

```hcl
terraform { ... }          # settings: required_version, required_providers, backend
provider "aws" { ... }     # configure a provider
resource "aws_s3_bucket" "this" { ... }   # manage a real thing
data "aws_ami" "this" { ... }             # read an existing thing
variable "name" { ... }    # input
output "name" { ... }      # output
locals { ... }             # named local values
module "name" { ... }      # call a child module
moved { ... } / removed { ... } / import { ... } / check { ... }   # special blocks
```

**Gotchas**
- `resource "aws_s3_bucket" "this"` → type is `aws_s3_bucket`, name is `this`. Address is `aws_s3_bucket.this`.
- The `terraform {}` block can't use variables or most functions — it's evaluated very early.
- Comments: `#` or `//` for single line, `/* */` for block.

**Drill A1**
> Write a `terraform {}` block that requires Terraform >= 1.6 and the AWS provider `~> 5.0` from `hashicorp/aws`.

<details><summary>Solution</summary>

```hcl
terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```
</details>

---

## A2. Types & Values

Primitive: `string`, `number`, `bool`. Collection: `list(...)`, `set(...)`, `map(...)`. Structural: `object({...})`, `tuple([...])`. Plus `null` and `any`.

```hcl
"hello"                              # string
42        3.14                       # number
true                                 # bool
["a", "b", "c"]                      # list/tuple
{ name = "web", size = 3 }           # map/object
toset(["a", "b", "a"])               # set → {"a","b"}
null                                 # absence of value
```

**Key distinctions (interviewers love these):**
- **list vs set:** lists are ordered & indexable (`x[0]`); sets are unordered, deduplicated, NOT indexable. `for_each` requires a set or map.
- **map vs object:** map values are all the *same* type; object attributes can each have *different* types and named keys.
- **tuple vs list:** tuple elements can have different types; list elements all share one type.

**Type constraints with `optional()`:**

```hcl
variable "server" {
  type = object({
    name    = string
    size    = optional(number, 1)   # default 1 if omitted
    tags    = optional(map(string), {})
  })
}
```

**Drill A2.1** — In `terraform console`, predict each, then verify:

```hcl
length(["a","b","c"])
length(toset(["a","a","b"]))
tolist(toset(["c","a","b"]))      # what order?
{ for k, v in { a=1, b=2 } : k => v * 10 }
type([1, "two", true])
```

<details><summary>Answers</summary>

- `3`
- `2` (set dedupes)
- `["a", "b", "c"]` — set converted to list comes back **sorted**, not insertion order
- `{ a = 10, b = 20 }`
- `tuple([number, string, bool])`
</details>

**Drill A2.2** — Write a variable `instances` of type: a map where each key maps to an object with `ami` (string), `type` (string, default `"t3.micro"`), and `public` (bool, default false).

<details><summary>Solution</summary>

```hcl
variable "instances" {
  type = map(object({
    ami    = string
    type   = optional(string, "t3.micro")
    public = optional(bool, false)
  }))
}
```
</details>

---

## A3. Variables (Inputs) — Full Treatment

```hcl
variable "environment" {
  type        = string
  description = "Deployment environment"
  default     = "dev"
  nullable    = false

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}
```

- `sensitive = true` hides the value in CLI output (but it's still **plaintext in state**).
- `nullable = false` rejects `null`.
- Multiple `validation` blocks allowed; all must pass.
- **Precedence (low→high):** default → `terraform.tfvars` / `*.auto.tfvars` → `TF_VAR_*` env → `-var` / `-var-file` on CLI.

**Drill A3** — Add a validation to a `cidr_block` variable that ensures it's a valid CIDR and is a /16 or larger (prefix ≤ 16).

<details><summary>Solution</summary>

```hcl
variable "cidr_block" {
  type = string
  validation {
    condition = can(cidrhost(var.cidr_block, 0)) &&
                tonumber(split("/", var.cidr_block)[1]) <= 16
    error_message = "Must be a valid CIDR with prefix /16 or larger."
  }
}
```
`can()` swallows errors and returns a bool — perfect for validation.
</details>

---

## A4. Expressions, Operators & Conditionals

```hcl
# references
var.name              local.x              aws_s3_bucket.this.arn
data.aws_ami.x.id     module.vpc.vpc_id    each.key / each.value / count.index

# operators
a + b   a - b   a * b   a / b   a % b
a == b  a != b  a < b   a > b
a && b  a || b  !a

# ternary conditional
var.env == "prod" ? "m5.large" : "t3.micro"

# string interpolation & directives
"server-${var.env}-${count.index}"
"%{ if var.enabled }on%{ else }off%{ endif }"
```

**Splat expressions** (shortcut for extracting attributes from a list):

```hcl
aws_instance.web[*].id        # list of all ids
# equivalent to: [for i in aws_instance.web : i.id]
```

**Drill A4** — Predict in console:

```hcl
true ? "yes" : "no"
3 > 2 && 1 > 5
"${upper("eu")}-${lower("WEST")}-1"
[for n in [1,2,3,4] : n if n % 2 == 0]
```

<details><summary>Answers</summary>
`"yes"` · `false` · `"EU-west-1"` · `[2, 4]`
</details>

---

## A5. `for` Expressions (the big one)

Produce a **list** with `[ ]` or a **map/object** with `{ }`.

```hcl
# list comprehension
[for s in var.list : upper(s)]

# list with filter
[for s in var.list : s if length(s) > 3]

# map comprehension (note the => arrow)
{ for k, v in var.map : k => v * 2 }

# building a map from a list (common pattern)
{ for inst in var.instances : inst.name => inst.type }

# index + value from a list
[for i, v in var.list : "${i}:${v}"]

# grouping mode (advanced) — multiple values per key
{ for s in var.servers : s.az => s.name... }   # the ... groups into lists
```

**Drill A5.1** — Given `var.users = ["alice", "bob", "carol"]`, build a map `{ alice = "alice@corp.com", ... }`.

<details><summary>Solution</summary>

```hcl
{ for u in var.users : u => "${u}@corp.com" }
```
</details>

**Drill A5.2** — Given a list of objects:
```hcl
locals {
  servers = [
    { name = "web1", az = "a" },
    { name = "web2", az = "b" },
    { name = "web3", az = "a" },
  ]
}
```
Build a map grouping server names by AZ: `{ a = ["web1","web3"], b = ["web2"] }`.

<details><summary>Solution</summary>

```hcl
{ for s in local.servers : s.az => s.name... }
```
The `...` (grouping mode) collects all values that share a key into a list.
</details>

**Drill A5.3** — Convert a list of objects into a map keyed by `name` (a *very* common `for_each` prep step):

<details><summary>Solution</summary>

```hcl
{ for s in local.servers : s.name => s }
```
Now you can `for_each = local.servers_by_name` safely.
</details>

---

## A6. `count` vs `for_each` — Master This

```hcl
# count — creates indexed instances [0], [1], [2]
resource "aws_instance" "web" {
  count = 3
  ami   = var.ami
  tags  = { Name = "web-${count.index}" }
}
# addresses: aws_instance.web[0], aws_instance.web[1], aws_instance.web[2]

# for_each — creates keyed instances ["a"], ["b"]
resource "aws_instance" "web" {
  for_each = toset(["app", "db", "cache"])
  ami      = var.ami
  tags     = { Name = each.key }
}
# addresses: aws_instance.web["app"], aws_instance.web["db"], ...
```

**The reindexing trap (memorize this):** with `count`, removing a *middle* element shifts every later index, so Terraform plans to destroy/recreate everything after it. With `for_each`, each instance is keyed by a stable string, so removing one only touches that one.

**Rules of thumb:**
- Default to `for_each`. Use `count` only for "N identical copies" or simple on/off (`count = var.enabled ? 1 : 0`).
- `for_each` needs a **set of strings** or a **map**. Convert lists with `toset()`.

**Drill A6.1** — Create one S3 bucket per environment from `var.envs = ["dev","staging","prod"]`, named `myapp-<env>`.

<details><summary>Solution</summary>

```hcl
resource "aws_s3_bucket" "env" {
  for_each = toset(var.envs)
  bucket   = "myapp-${each.key}"
}
```
</details>

**Drill A6.2** — Conditionally create a resource only when `var.create_logging == true`.

<details><summary>Solution</summary>

```hcl
resource "aws_s3_bucket" "logs" {
  count  = var.create_logging ? 1 : 0
  bucket = "myapp-logs"
}
# reference the (maybe-absent) resource with: aws_s3_bucket.logs[0].id
# or safely: one(aws_s3_bucket.logs[*].id)
```
</details>

**Drill A6.3 (debug)** — What's wrong and how do you fix it?

```hcl
resource "aws_subnet" "this" {
  for_each = ["10.0.1.0/24", "10.0.2.0/24"]
  cidr_block = each.value
}
```

<details><summary>Answer</summary>
`for_each` can't take a plain **list** — it needs a set or map. Wrap it: `for_each = toset([...])`. Then `each.key == each.value` for a set.
</details>

---

## A7. Built-in Functions — The Working Set

You don't need all ~120. Master these by category. **Test each in `terraform console`.**

**String:** `format`, `join`, `split`, `replace`, `trimspace`, `lower`/`upper`/`title`, `substr`, `startswith`/`endswith`, `regex`, `regexall`
**Collection:** `length`, `concat`, `contains`, `keys`, `values`, `lookup`, `merge`, `flatten`, `distinct`, `element`, `index`, `slice`, `sort`, `reverse`, `setunion`/`setintersection`, `zipmap`, `coalesce`, `coalescelist`, `compact`, `chunklist`
**Type/conversion:** `tostring`, `tonumber`, `tolist`, `toset`, `tomap`, `try`, `can`, `one`, `nonsensitive`
**Numeric:** `min`, `max`, `abs`, `ceil`, `floor`, `pow`, `parseint`
**Encoding:** `jsonencode`/`jsondecode`, `yamlencode`/`yamldecode`, `base64encode`/`base64decode`, `urlencode`
**Filesystem/template:** `file`, `templatefile`, `fileexists`, `pathexpand`, `abspath`, `dirname`, `basename`
**Crypto/hash:** `md5`, `sha256`, `bcrypt`, `uuid`, `filemd5`
**IP/network:** `cidrhost`, `cidrsubnet`, `cidrsubnets`, `cidrnetmask`
**Date:** `timestamp`, `timeadd`, `formatdate`

**Drill A7 — predict each:**

```hcl
merge({a=1, b=2}, {b=3, c=4})
lookup({a=1}, "z", "default")
coalesce(null, "", "fallback")        # careful!
cidrsubnet("10.0.0.0/16", 8, 5)
flatten([[1,2],[3],[4,5]])
try(var.maybe_missing.key, "safe")
join("-", ["a","b","c"])
format("ip-%03d", 7)
zipmap(["a","b"], [1,2])
```

<details><summary>Answers</summary>

- `{a=1, b=3, c=4}` (later wins)
- `1` (key exists, default ignored)
- `""` — `coalesce` skips `null` but `""` is a valid non-null value, so it returns `""`. (Use `coalesce(null, null, "fallback")` to see `"fallback"`.)
- `"10.0.5.0/24"`
- `[1,2,3,4,5]`
- `"safe"` (if the path errors)
- `"a-b-c"`
- `"ip-007"`
- `{a=1, b=2}`
</details>

---

## A8. `locals` — Computation & DRY

```hcl
locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }
  # locals can reference earlier locals
  bucket_name = "${local.name_prefix}-assets"
}
```

Use locals to: name things consistently, build the tag map once, reshape data for `for_each`, and avoid repeating expressions.

**Drill A8** — Build a `local.subnet_map` of `{ "us-east-1a" = "10.0.0.0/24", "us-east-1b" = "10.0.1.0/24", "us-east-1c" = "10.0.2.0/24" }` from `var.azs = ["us-east-1a","us-east-1b","us-east-1c"]` and base CIDR `10.0.0.0/16`, computed dynamically.

<details><summary>Solution</summary>

```hcl
locals {
  subnet_map = {
    for idx, az in var.azs :
    az => cidrsubnet("10.0.0.0/16", 8, idx)
  }
}
```
</details>

---

## A9. `dynamic` Blocks

Generate repeated nested blocks from a collection.

```hcl
variable "ingress_rules" {
  type = list(object({
    port        = number
    cidr_blocks = list(string)
  }))
}

resource "aws_security_group" "this" {
  name = "web"
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}
```

The iterator defaults to the block name (`ingress.value`). Rename with `iterator = rule`.

**Drill A9** — Use a `dynamic` block to create one `ingress` rule per port in `var.allowed_ports = [22, 80, 443]`, each open to `0.0.0.0/0`.

<details><summary>Solution</summary>

```hcl
dynamic "ingress" {
  for_each = toset(var.allowed_ports)
  content {
    from_port   = ingress.value
    to_port     = ingress.value
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```
</details>

---

## A10. Lifecycle Meta-Arguments

```hcl
resource "aws_instance" "web" {
  # ...
  lifecycle {
    create_before_destroy = true                    # new before old (zero downtime)
    prevent_destroy       = true                    # block accidental destroy
    ignore_changes        = [tags["LastModified"]]  # ignore drift on specific attrs
    replace_triggered_by  = [aws_launch_template.web.latest_version]
  }
}
```

- `create_before_destroy`: for resources that can't have downtime; watch for name collisions.
- `prevent_destroy`: errors any plan that would destroy it (good for prod DBs/buckets).
- `ignore_changes`: stop fighting external systems that mutate a field; use `all` sparingly.
- `replace_triggered_by`: force replacement when *another* resource/attr changes.

**Drill A10** — You have an ASG whose instances are tagged by an external autoscaler with a `LaunchedAt` tag. Stop Terraform from reverting it, but still manage all other tags.

<details><summary>Solution</summary>

```hcl
lifecycle {
  ignore_changes = [tag["LaunchedAt"]]   # or tags["LaunchedAt"] depending on attr
}
```
</details>

---

## A11. Data Sources & Resource References

```hcl
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "web" {
  ami = data.aws_ami.al2023.id   # implicit dependency
}
```

The reference `data.aws_ami.al2023.id` creates an **implicit dependency** — Terraform reads the AMI before creating the instance. You almost never need `depends_on`.

**Drill A11** — Use the `aws_availability_zones` data source to get all available AZs and create one subnet in each (use the names you fetched).

<details><summary>Solution</summary>

```hcl
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "this" {
  for_each          = toset(data.aws_availability_zones.available.names)
  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, index(data.aws_availability_zones.available.names, each.key))
}
```
</details>

---

## A12. Outputs

```hcl
output "instance_ids" {
  description = "IDs of all web instances"
  value       = aws_instance.web[*].id
  sensitive   = false
}
```

Outputs are how modules expose values to callers and how you surface info to the user/CI. Mark secrets `sensitive`. Outputs can have `precondition` blocks.

**Drill A12** — Output a map of `{ instance_name => private_ip }` for `for_each`-created instances `aws_instance.web`.

<details><summary>Solution</summary>

```hcl
output "ips" {
  value = { for k, inst in aws_instance.web : k => inst.private_ip }
}
```
</details>

---

## A13. Modules — Language Level

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "main"
  cidr = "10.0.0.0/16"

  # pass provider explicitly when needed
  providers = { aws = aws.us_east_1 }
}

# consume outputs
resource "aws_instance" "x" {
  subnet_id = module.vpc.private_subnets[0]
}
```

- Module `source` can be: local path (`./modules/vpc`), registry, Git, S3.
- `count` and `for_each` work on **module blocks** too.
- A module's `variable` blocks are its inputs; its `output` blocks are what callers read.

**Drill A13** — Call a local module `./modules/bucket` once per environment, passing `environment = each.key`.

<details><summary>Solution</summary>

```hcl
module "bucket" {
  source   = "./modules/bucket"
  for_each = toset(["dev", "staging", "prod"])

  environment = each.key
}
# read: module.bucket["prod"].bucket_arn
```
</details>

---

## A14. Refactoring Blocks — `moved`, `removed`, `import`

```hcl
# rename without destroy/recreate
moved {
  from = aws_instance.web
  to   = aws_instance.app
}

# stop managing without destroying the real resource
removed {
  from = aws_s3_bucket.legacy
  lifecycle { destroy = false }
}

# declarative import (modern, plan-reviewable)
import {
  to = aws_s3_bucket.existing
  id = "my-existing-bucket-name"
}
```

These are **004 exam favorites**. `moved` is for refactors (renames, moving into modules). `import` brings existing infra under management. `removed` drops it from state safely.

**Drill A14** — You're moving `aws_instance.web` into a module `compute`. Write the `moved` block so no recreation happens.

<details><summary>Solution</summary>

```hcl
moved {
  from = aws_instance.web
  to   = module.compute.aws_instance.this
}
```
</details>

---

## A15. Custom Conditions & Checks

```hcl
resource "aws_instance" "web" {
  ami = var.ami

  lifecycle {
    precondition {
      condition     = data.aws_ami.selected.architecture == "x86_64"
      error_message = "AMI must be x86_64."
    }
    postcondition {
      condition     = self.public_ip != ""
      error_message = "Instance must receive a public IP."
    }
  }
}

# standalone health assertion (warns, doesn't block)
check "endpoint_healthy" {
  data "http" "ping" {
    url = "https://${aws_lb.this.dns_name}/health"
  }
  assert {
    condition     = data.http.ping.status_code == 200
    error_message = "Health endpoint did not return 200."
  }
}
```

`precondition` runs before the resource is created (validates assumptions). `postcondition` runs after (validates guarantees). `check` blocks are non-blocking continuous validation.

---

## A16. Sensitive, Ephemeral & Write-Only (004-heavy)

- `sensitive = true`: redacts from output **but is stored in state as plaintext.**
- **Ephemeral values / write-only attributes** (Terraform 1.10+): values that exist only during a run and are **never persisted to state** — the modern way to pass secrets (e.g., a DB password) without leaking them.

```hcl
variable "db_password" {
  type      = string
  ephemeral = true        # not stored in state
}

resource "aws_db_instance" "this" {
  password_wo         = var.db_password   # write-only attribute (never in state)
  password_wo_version = 1
}
```

**Self-check:** What's the difference between `sensitive` and `ephemeral`? (`sensitive` only hides from *display*; `ephemeral`/write-only keeps it out of *state* entirely.)

---

## A17. Templating & Provisioners

```hcl
# templatefile — render a file with variables
user_data = templatefile("${path.module}/init.sh.tftpl", {
  region = var.region
  ports  = [80, 443]
})
```

`init.sh.tftpl`:
```bash
#!/bin/bash
echo "Region: ${region}"
%{ for p in ports ~}
echo "Opening port ${p}"
%{ endfor ~}
```

Provisioners are a **last resort** (not tracked in state, run only on create/destroy):

```hcl
resource "aws_instance" "web" {
  # ...
  provisioner "local-exec" {
    command = "echo ${self.private_ip} >> hosts.txt"
  }
}
```

Prefer `user_data`/`cloud-init` over `remote-exec` every time.

---

# PART B — Mixed Drills (Type, Don't Read)

Do these in order. Each builds on the last.

1. Declare a `map(object(...))` variable `apps` where each app has `image` (string), `replicas` (number, default 2), `env` (map(string), default {}).
2. Write a `for` expression that returns only the apps with `replicas > 2`.
3. Create an `aws_s3_bucket` per app using `for_each`, bucket = `<appname>-data`.
4. Add `aws_s3_bucket_versioning` for each bucket (hint: `for_each` over the same map, reference `aws_s3_bucket.this[each.key].id`).
5. Output a map of `{ appname => bucket_arn }`.
6. Add a `validation` to `apps` ensuring no app name is longer than 20 chars.
7. Add `common_tags` local and merge it into every bucket's tags.
8. Refactor: you renamed `aws_s3_bucket.this` to `aws_s3_bucket.app`. Add the `moved` block.

<details><summary>Reference solution</summary>

```hcl
variable "apps" {
  type = map(object({
    image    = string
    replicas = optional(number, 2)
    env      = optional(map(string), {})
  }))
  validation {
    condition     = alltrue([for name in keys(var.apps) : length(name) <= 20])
    error_message = "App names must be 20 characters or fewer."
  }
}

locals {
  common_tags  = { ManagedBy = "terraform", Project = "workbook" }
  big_apps     = { for k, v in var.apps : k => v if v.replicas > 2 }
}

resource "aws_s3_bucket" "app" {       # (renamed from .this)
  for_each = var.apps
  bucket   = "${each.key}-data"
  tags     = merge(local.common_tags, { App = each.key })
}

resource "aws_s3_bucket_versioning" "app" {
  for_each = aws_s3_bucket.app
  bucket   = each.value.id
  versioning_configuration { status = "Enabled" }
}

output "bucket_arns" {
  value = { for k, b in aws_s3_bucket.app : k => b.arn }
}

moved {
  from = aws_s3_bucket.this
  to   = aws_s3_bucket.app
}
```
</details>

---

# PART C — Output-Prediction Quiz

For each, write the result *before* checking. Use `terraform console` to verify.

```hcl
Q1.  setunion(toset([1,2,3]), toset([3,4]))
Q2.  [for i in range(3) : i * i]
Q3.  contains(["a","b"], "c")
Q4.  element(["x","y","z"], 4)            # note: 4, not 2
Q5.  slice([10,20,30,40], 1, 3)
Q6.  lookup({}, "k", "fallback")
Q7.  can(tonumber("abc"))
Q8.  jsonencode({ a = 1, b = [true, null] })
Q9.  formatdate("YYYY-MM-DD", "2026-05-31T10:00:00Z")
Q10. cidrsubnets("10.0.0.0/16", 4, 4, 8)
Q11. compact(["a", "", "b", ""])
Q12. distinct([1,1,2,3,3])
Q13. coalescelist([], [], ["x"])
Q14. zipmap(["a","b","c"], [1,2,3])["b"]
Q15. trimsuffix("image.png", ".png")
```

<details><summary>Answers</summary>

1. `[1, 2, 3, 4]` (sets sort)
2. `[0, 1, 4]`
3. `false`
4. `"y"` — `element` **wraps around** (4 % 3 = 1)
5. `[20, 30]`
6. `"fallback"`
7. `false` — `tonumber("abc")` errors, `can` catches it
8. `{"a":1,"b":[true,null]}`
9. `"2026-05-31"`
10. `["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/24"]`
11. `["a", "b"]`
12. `[1, 2, 3]`
13. `["x"]`
14. `2`
15. `"image"`
</details>

---

# PART D — "Debug This Code" Quiz

Each snippet has a bug. Find it and fix it.

**D1**
```hcl
resource "aws_instance" "web" {
  for_each = ["a", "b"]
  ami      = var.ami
}
```

**D2**
```hcl
variable "tags" {
  type    = map(string)
  default = { Env = "dev", Count = 3 }
}
```

**D3**
```hcl
resource "aws_subnet" "x" {
  count      = length(var.azs)
  cidr_block = cidrsubnet(var.cidr, 8, count.index)
}

resource "aws_route_table_association" "x" {
  for_each       = aws_subnet.x
  subnet_id      = each.value.id
  route_table_id = aws_route_table.x.id
}
```

**D4**
```hcl
output "password" {
  value = var.db_password
}
```

**D5**
```hcl
locals {
  name = "${var.project}-${var.env}"
}
terraform {
  required_version = local.name   # ?
}
```

<details><summary>Answers</summary>

**D1** — `for_each` can't take a list. `for_each = toset(["a", "b"])`.

**D2** — Map values must be a single type. `Count = 3` (number) breaks a `map(string)`. Use `"3"` or change the type.

**D3** — `count`-based resources produce a **list**, but `for_each` over `aws_subnet.x` expects a map/set keyed predictably. Either switch the subnet to `for_each` too, or do `for_each = { for i, s in aws_subnet.x : i => s }`. Mixing `count` upstream and `for_each` downstream is fragile — make both `for_each`.

**D4** — Exposing a secret in an output without `sensitive = true` (and ideally it shouldn't be an output at all). Add `sensitive = true` or remove it.

**D5** — The `terraform {}` block is evaluated too early to use `local`/`var`/functions. `required_version` must be a literal string like `">= 1.6"`.
</details>

---

# PART E — Real-World Scenario Coding Challenges

Each gives a **problem statement** and **acceptance criteria**. Build it in your sandbox, then compare to the solution sketch. These mirror take-home and live-coding interview tasks.

---

### Scenario E1 — Tag Governance Across All Resources
**Problem:** Your org mandates that every resource carry `Project`, `Environment`, `Owner`, and `ManagedBy=terraform` tags. Make this DRY and impossible to forget.

**Acceptance:** A single tag definition; applied to 3+ resource types; `Owner` comes from a variable with validation that it's an email.

<details><summary>Solution sketch</summary>

```hcl
variable "owner" {
  type = string
  validation {
    condition     = can(regex("^[^@]+@[^@]+\\.[^@]+$", var.owner))
    error_message = "Owner must be a valid email."
  }
}

locals {
  base_tags = {
    Project     = var.project
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "terraform"
  }
}

resource "aws_s3_bucket" "a" {
  bucket = "${var.project}-a"
  tags   = merge(local.base_tags, { Name = "a" })
}
# (the AWS provider's default_tags is the even cleaner answer — mention it!)
provider "aws" {
  default_tags { tags = local.base_tags }
}
```
**Interview gold:** mention `provider "aws" { default_tags { ... } }` as the truly DRY answer — it auto-applies to all resources.
</details>

---

### Scenario E2 — Build a Reusable VPC Module
**Problem:** Write a `./modules/vpc` module that creates a VPC, public + private subnets across N AZs, an IGW, a NAT gateway, and route tables.

**Acceptance:** Inputs = `name`, `cidr`, `az_count`, `enable_nat`. Outputs = `vpc_id`, `public_subnet_ids`, `private_subnet_ids`. Subnets sized automatically from the VPC CIDR. NAT optional.

<details><summary>Solution sketch (modules/vpc/main.tf)</summary>

```hcl
data "aws_availability_zones" "available" { state = "available" }

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
}

resource "aws_vpc" "this" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true
  tags                 = { Name = var.name }
}

resource "aws_subnet" "public" {
  for_each          = { for i, az in local.azs : az => i }
  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(var.cidr, 8, each.value)
  map_public_ip_on_launch = true
  tags              = { Name = "${var.name}-public-${each.key}", Tier = "public" }
}

resource "aws_subnet" "private" {
  for_each          = { for i, az in local.azs : az => i }
  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(var.cidr, 8, each.value + 100)
  tags              = { Name = "${var.name}-private-${each.key}", Tier = "private" }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

resource "aws_eip" "nat" {
  count  = var.enable_nat ? 1 : 0
  domain = "vpc"
}

resource "aws_nat_gateway" "this" {
  count         = var.enable_nat ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = values(aws_subnet.public)[0].id
}

# variables.tf
variable "name"      { type = string }
variable "cidr"      { type = string }
variable "az_count"  { type = number, default = 2 }   # write each on its own line in real files
variable "enable_nat"{ type = bool,   default = true }

# outputs.tf
output "vpc_id"             { value = aws_vpc.this.id }
output "public_subnet_ids"  { value = [for s in aws_subnet.public  : s.id] }
output "private_subnet_ids" { value = [for s in aws_subnet.private : s.id] }
```
</details>

---

### Scenario E3 — Environment Config Without Repetition
**Problem:** Deploy the same stack to dev/staging/prod where prod is bigger. No copy-pasted resource blocks.

**Acceptance:** One `locals` map drives sizing; switching env changes instance type, count, and Multi-AZ.

<details><summary>Solution sketch</summary>

```hcl
locals {
  env_config = {
    dev     = { instance_type = "t3.micro",  count = 1, multi_az = false }
    staging = { instance_type = "t3.small",  count = 2, multi_az = false }
    prod    = { instance_type = "m5.large",  count = 4, multi_az = true  }
  }
  cfg = local.env_config[var.environment]
}

resource "aws_instance" "app" {
  count         = local.cfg.count
  instance_type = local.cfg.instance_type
  ami           = var.ami
}

resource "aws_db_instance" "db" {
  multi_az          = local.cfg.multi_az
  instance_class    = local.cfg.multi_az ? "db.m5.large" : "db.t3.small"
  # ...
}
```
</details>

---

### Scenario E4 — Import Existing (Brownfield) Infra
**Problem:** A teammate created an S3 bucket `legacy-prod-assets` and a security group `sg-0abc123` by hand. Bring them under Terraform **without recreating them**.

**Acceptance:** Use declarative `import` blocks; `terraform plan` shows **no changes** (or only safe tag additions) after import.

<details><summary>Solution sketch</summary>

```hcl
import {
  to = aws_s3_bucket.legacy
  id = "legacy-prod-assets"
}
resource "aws_s3_bucket" "legacy" {
  bucket = "legacy-prod-assets"
  # fill attributes to MATCH reality so plan shows no diff
}

import {
  to = aws_security_group.web
  id = "sg-0abc123"
}
resource "aws_security_group" "web" {
  # match existing rules exactly, then iterate
}
```
**Workflow tip:** run `terraform plan -generate-config-out=generated.tf` to scaffold the matching config, then clean it up. Mention this in interviews.
</details>

---

### Scenario E5 — Multi-Region / Multi-Provider
**Problem:** Replicate an S3 bucket into `us-east-1` and `eu-west-1` for DR.

**Acceptance:** Two provider aliases; one bucket per region; cross-region replication optional.

<details><summary>Solution sketch</summary>

```hcl
provider "aws" {
  region = "us-east-1"
}
provider "aws" {
  alias  = "eu"
  region = "eu-west-1"
}

resource "aws_s3_bucket" "primary" {
  bucket = "${var.project}-primary"
}

resource "aws_s3_bucket" "dr" {
  provider = aws.eu
  bucket   = "${var.project}-dr"
}
```
</details>

---

### Scenario E6 — Safe Refactor: Resource → Module
**Problem:** You have flat `aws_instance.web` and `aws_security_group.web` resources. Move them into a `module "compute"` with zero recreation.

**Acceptance:** `moved` blocks for each; `terraform plan` shows **0 to add, 0 to change, 0 to destroy**.

<details><summary>Solution sketch</summary>

```hcl
module "compute" {
  source = "./modules/compute"
  # inputs...
}

moved {
  from = aws_instance.web
  to   = module.compute.aws_instance.this
}
moved {
  from = aws_security_group.web
  to   = module.compute.aws_security_group.this
}
```
</details>

---

### Scenario E7 — Dynamic Security Group from Config
**Problem:** Drive SG ingress rules entirely from a variable so app teams can self-service without editing HCL.

**Acceptance:** `var.rules` is a list of objects; `dynamic "ingress"` generates them; supports per-rule description and multiple CIDRs.

<details><summary>Solution sketch</summary>

```hcl
variable "rules" {
  type = list(object({
    description = optional(string, "")
    port        = number
    protocol    = optional(string, "tcp")
    cidr_blocks = list(string)
  }))
}

resource "aws_security_group" "this" {
  name = "${var.name}-sg"
  dynamic "ingress" {
    for_each = var.rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}
```
</details>

---

### Scenario E8 — Secrets Done Right
**Problem:** An RDS instance needs a password. It must never appear in state.

**Acceptance:** Use an ephemeral variable + write-only attribute (or pull from Secrets Manager). Demonstrate the password is absent from `terraform.tfstate`.

<details><summary>Solution sketch</summary>

```hcl
# Option A: write-only / ephemeral (Terraform 1.11+)
variable "db_password" {
  type      = string
  ephemeral = true
}
resource "aws_db_instance" "this" {
  username            = "admin"
  password_wo         = var.db_password
  password_wo_version = 1
  # ...
}

# Option B: pull from Secrets Manager (no secret in code at all)
data "aws_secretsmanager_secret_version" "db" {
  secret_id = "prod/db/password"
}
# use jsondecode(data...secret_string)["password"] — but note this DOES land in state,
# which is why write-only attributes are the modern preference.
```
**Interview point:** explain *why* plain `sensitive` is insufficient (state is plaintext).
</details>

---

# PART F — `terraform console` Practice Session

Paste these one at a time to build expression fluency. Predict, then run.

```hcl
> var.environment
> local.common_tags
> aws_s3_bucket.app
> keys(var.apps)
> [for k, v in var.apps : k if v.replicas > 1]
> cidrsubnet(var.cidr, 8, 3)
> { for az in var.azs : az => index(var.azs, az) }
> try(var.optional_thing, "default")
> length(aws_instance.web)
```

Run `terraform console` after a successful `apply` so resource values resolve to real data.

---

# PART G — Self-Assessment Checklist (Language Mastery)

You're language-fluent when you can, **without docs**:

- [ ] Write any of the 8 type constraints from memory, including `optional()` with defaults.
- [ ] Convert a list of objects into a map keyed by a field, for `for_each`.
- [ ] Explain & demonstrate the `count` reindexing bug.
- [ ] Write a grouping `for` expression (`...`).
- [ ] Use `dynamic` blocks with a custom iterator.
- [ ] Reach for the right function among `merge`/`lookup`/`coalesce`/`try`/`flatten` instantly.
- [ ] Write all four lifecycle meta-args with a real use case each.
- [ ] Write `moved`, `import`, and `removed` blocks correctly.
- [ ] Add `precondition`/`postcondition`/`check` assertions.
- [ ] Explain `sensitive` vs `ephemeral`/write-only and prove a secret is absent from state.
- [ ] Render a `templatefile` with a `%{ for }` directive.
- [ ] Predict `plan` output (`+ ~ - -/+`) for a given change.

When every box is checked, do the roadmap's Project 3 and 4 — your bottleneck will be AWS knowledge, not HCL.

---

## Suggested Order to Work This Workbook
1. **Days 1–3:** Part A sections A1–A8 + their drills (the core language).
2. **Days 4–5:** A9–A13 (dynamic, lifecycle, data, modules) + Part B mixed drills.
3. **Day 6:** A14–A17 (refactor blocks, conditions, secrets, templating) — the 004 deltas.
4. **Daily throughout:** 10 questions from Parts C/D, 1 scenario from Part E.
5. **Before cert:** Part G checklist must be all ✅.
