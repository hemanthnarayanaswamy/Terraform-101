# GCP IAM with Terraform: Capstone Practice Lab

## Objective

Build a reusable, multi-environment GCP IAM platform using Terraform.

The goal is to practice the most important Terraform and GCP IAM concepts in one project, including:

- Service accounts
- Project-level IAM
- Resource-level IAM
- Service-account impersonation
- Predefined roles
- Custom roles
- IAM Conditions
- Users, groups, and service accounts as principals
- Variables and complex data types
- Locals and data transformation
- `for_each`
- Nested `for` expressions
- Modules
- Module outputs
- Environment separation
- Remote state
- Importing existing resources
- Refactoring with `moved` blocks
- Drift detection
- Variable validation
- Terraform state management

---

# 1. Scenario

A company has three applications:

```text
web
api
analytics
```

Each application needs:

- Its own service account
- Project-level IAM roles
- Resource-specific access
- Optional service-account impersonation
- Different permissions in development and production

The Terraform platform must also support:

- Existing users
- Google groups
- Existing service accounts
- Predefined roles
- Custom roles
- Conditional temporary access
- Reusable Terraform modules
- Multiple environments
- Remote Terraform state

---

# 2. Architecture

```text
Existing GCP Project
│
├── Terraform IAM Platform
│   │
│   ├── Service Accounts
│   │   ├── web-dev
│   │   ├── api-dev
│   │   └── analytics-dev
│   │
│   ├── Project-Level IAM
│   │   ├── Predefined roles
│   │   ├── Custom roles
│   │   └── Conditional roles
│   │
│   ├── Resource-Level IAM
│   │   └── Cloud Storage bucket IAM
│   │
│   └── Service Account IAM
│       ├── Service Account User
│       └── Service Account Token Creator
│
├── Reusable Modules
│   ├── service-account
│   ├── project-iam
│   ├── service-account-iam
│   ├── custom-role
│   └── bucket-iam
│
└── Environments
    ├── dev
    └── prod
```

---

# 3. Important IAM Mental Model

A service account has two identities.

## Service account as a principal

The service account receives access to another resource.

```text
API service account
    ↓
roles/secretmanager.secretAccessor
    ↓
GCP project
```

```hcl
resource "google_project_iam_member" "example" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.api.email}"
}
```

## Service account as a resource

A user, group, workload, or another service account receives permission to use or impersonate the service account.

Example:

```text
Developer
    ↓
roles/iam.serviceAccountTokenCreator
    ↓
API service account
```

Terraform resource:

```hcl
resource "google_service_account_iam_member" "example" {
  service_account_id = google_service_account.api.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "user:developer@example.com"
}
```

Remember:

```text
Service account needs access to project
    → google_project_iam_member

Principal needs access to service account
    → google_service_account_iam_member
```

# 4. Final Repository Structure

```text
gcp-iam-capstone/
├── README.md
├── .gitignore
│
├── bootstrap/
│   ├── versions.tf
│   ├── providers.tf
│   ├── variables.tf
│   ├── main.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
│
├── modules/
│   ├── service-account/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   │
│   ├── project-iam/
│   │   ├── main.tf
│   │   ├── locals.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   │
│   ├── service-account-iam/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   │
│   ├── custom-role/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   │
│   └── bucket-iam/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md
│
└── environments/
    ├── dev/
    │   ├── versions.tf
    │   ├── providers.tf
    │   ├── variables.tf
    │   ├── locals.tf
    │   ├── main.tf
    │   ├── outputs.tf
    │   ├── backend.tf
    │   ├── terraform.tfvars.example
    │   └── README.md
    │
    └── prod/
        ├── versions.tf
        ├── providers.tf
        ├── variables.tf
        ├── locals.tf
        ├── main.tf
        ├── outputs.tf
        ├── backend.tf
        ├── terraform.tfvars.example
        └── README.md
```

Terraform evaluates all `.tf` files in the same directory as one module.

The filenames organize the code for humans. Terraform does not execute `versions.tf`, `main.tf`, and `outputs.tf` sequentially.

---

# 5. Business Requirements

## Requirement A: Create multiple service accounts

Create the following service accounts:

```text
web
api
analytics
```

Service-account IDs must include the environment:

```text
web-dev
api-dev
analytics-dev
```

Each service account must have:

- Account ID
- Display name
- Description
- Project ID
- Environment-specific name

Do not write three separate `google_service_account` blocks.

Use a map and `for_each`.

Example input:

```hcl
service_accounts = {
  web = {
    display_name = "Web application identity"
    description  = "Identity used by the web workload"

    project_roles = [
      "roles/logging.logWriter",
      "roles/monitoring.metricWriter"
    ]
  }

  api = {
    display_name = "API application identity"
    description  = "Identity used by the API workload"

    project_roles = [
      "roles/logging.logWriter",
      "roles/secretmanager.secretAccessor"
    ]
  }

  analytics = {
    display_name = "Analytics workload identity"
    description  = "Identity used by analytics workloads"

    project_roles = [
      "roles/bigquery.jobUser",
      "roles/bigquery.dataViewer"
    ]
  }
}
```

---

## Requirement B: Assign project-level roles

Assign these roles.

### Web service account

```text
roles/logging.logWriter
roles/monitoring.metricWriter
```

### API service account

```text
roles/logging.logWriter
roles/secretmanager.secretAccessor
```

### Analytics service account

```text
roles/bigquery.jobUser
roles/bigquery.dataViewer
```

Do not create one manually written IAM block for each role.

Use:

- Nested `for` expressions
- `flatten()`
- A map with stable keys
- `for_each`

---

## Requirement C: Support existing principals

Terraform must support IAM access for principals that Terraform does not create.

Supported principal types:

```text
user:
group:
serviceAccount:
domain:
```

Example:

```hcl
additional_project_access = {
  developers = {
    member = "group:developers@example.com"

    roles = [
      "roles/logging.viewer",
      "roles/monitoring.viewer"
    ]
  }

  team_lead = {
    member = "user:lead@example.com"

    roles = [
      "roles/iam.securityReviewer"
    ]
  }

  ci_runner = {
    member = "serviceAccount:existing-ci@example-project.iam.gserviceaccount.com"

    roles = [
      "roles/logging.viewer"
    ]
  }
}
```

If Google groups are not available in your account, keep group support in the Terraform design but use your user account or a disposable service account while testing.

---

## Requirement D: Service-account impersonation

Allow selected principals to impersonate specific service accounts.

Example:

```text
Developer principal
    → web service account

CI service account
    → api service account

CI service account
    → analytics service account
```

Example input:

```hcl
impersonation = {
  web_developer = {
    service_account_key = "web"
    member              = "user:developer@example.com"
    role                = "roles/iam.serviceAccountTokenCreator"
  }

  api_ci = {
    service_account_key = "api"
    member              = "serviceAccount:existing-ci@example-project.iam.gserviceaccount.com"
    role                = "roles/iam.serviceAccountTokenCreator"
  }

  analytics_ci = {
    service_account_key = "analytics"
    member              = "serviceAccount:existing-ci@example-project.iam.gserviceaccount.com"
    role                = "roles/iam.serviceAccountTokenCreator"
  }
}
```

Practice explaining the difference between:

```text
roles/iam.serviceAccountUser
roles/iam.serviceAccountTokenCreator
```

Do not assume they are interchangeable.

---

## Requirement E: Create a custom role

Create a project-level custom role:

```text
applicationLogReader
```

Example input:

```hcl
custom_roles = {
  application_log_reader = {
    role_id     = "applicationLogReader"
    title       = "Application Log Reader"
    description = "Allows approved application log-reading operations"

    permissions = [
      # Research and provide the approved permissions
    ]

    stage = "GA"
  }
}
```

Terraform resource:

```text
google_project_iam_custom_role
```

The resulting role name will resemble:

```text
projects/PROJECT_ID/roles/applicationLogReader
```

Assign the custom role to one supported principal.

The project-IAM module must accept both:

```text
roles/logging.viewer
```

and:

```text
projects/PROJECT_ID/roles/applicationLogReader
```

Do not hardcode the custom role inside the project-IAM module.

---

## Requirement F: Resource-level bucket IAM

Create one lab Cloud Storage bucket.

Use a globally unique bucket name:

```text
PROJECT_ID-iam-capstone-dev
```

Assign:

```text
web service account
    → roles/storage.objectViewer

api service account
    → roles/storage.objectCreator

analytics service account
    → roles/storage.objectViewer
```

Use:

```text
google_storage_bucket_iam_member
```

Do not give project-level Storage Admin when access to one bucket is sufficient.

This requirement demonstrates least privilege:

```text
Grant access at the smallest required resource boundary.
```

---

## Requirement G: Temporary conditional access

Give a test principal temporary access using an IAM Condition.

Example:

```text
Test developer
    → roles/storage.objectViewer
    → valid until an approved UTC timestamp
```

Conceptual block:

```hcl
condition {
  title       = "temporary_access"
  description = "Temporary access for IAM capstone practice"
  expression  = "request.time < timestamp(\"2026-12-31T23:59:59Z\")"
}
```

Use a future date when applying the lab.

Model the condition as optional:

```hcl
condition = optional(object({
  title       = string
  description = optional(string)
  expression  = string
}))
```

Use a dynamic block so that Terraform creates the `condition` block only when the caller supplies one.

Conceptual pattern:

```hcl
dynamic "condition" {
  for_each = each.value.condition == null ? [] : [each.value.condition]

  content {
    title       = condition.value.title
    description = try(condition.value.description, null)
    expression  = condition.value.expression
  }
}
```

---

## Requirement H: Multiple environments

Create:

```text
dev
prod
```

Both environments must use the same reusable modules.

The values and permissions must differ.

### Development

```text
More debugging access
More read-only access
Temporary developer access allowed
Deletion protection disabled where appropriate
```

### Production

```text
Fewer principals
More restrictive permissions
No basic roles
No temporary developer access by default
Deletion protection enabled where appropriate
```

Use separate environment directories:

```text
environments/dev
environments/prod
```

Do not apply production while learning. Build it and inspect the plan only after development works.

---

# 8. Build the Lab Incrementally

Do not create all modules immediately.

Build the project through six iterations.

---

# Iteration 1: Flat Root Configuration

Start inside:

```text
environments/dev/
```

Create:

```text
versions.tf
providers.tf
variables.tf
terraform.tfvars
main.tf
outputs.tf
```

Implement only:

```text
One service account
One project IAM role
One output
```

Dependency graph:

```text
Project ID input
      ↓
Service account
      ↓
Project IAM membership
      ↓
Service account email output
```

Run:

```bash
terraform fmt -recursive
terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform output
terraform state list
```

Expected state:

```text
google_service_account.application
google_project_iam_member.application
```

---

# Iteration 2: Multiple Service Accounts

Replace the single service-account input with a map.

```hcl
variable "service_accounts" {
  description = "Service accounts required by the environment"

  type = map(object({
    display_name  = string
    description   = optional(string)
    project_roles = set(string)
  }))
}
```

Create service accounts with:

```hcl
resource "google_service_account" "application" {
  for_each = var.service_accounts

  project      = var.project_id
  account_id   = "${each.key}-${var.environment}"
  display_name = each.value.display_name
  description  = try(each.value.description, null)
}
```

Expected resource addresses:

```text
google_service_account.application["web"]
google_service_account.application["api"]
google_service_account.application["analytics"]
```

Run:

```bash
terraform state list
```

Practice explaining why stable map keys are better than list indexes for named resources.

---

# Iteration 3: Flatten Service-Account Role Assignments

The input structure is nested:

```text
service account
    └── multiple roles
```

Each `google_project_iam_member` represents:

```text
one project
one role
one principal
```

Transform this:

```text
web
├── role A
└── role B

api
├── role A
└── role C
```

Into this:

```text
web-role-A
web-role-B
api-role-A
api-role-C
```

Create the flattened list:

```hcl
locals {
  service_account_project_roles = flatten([
    for account_key, account in var.service_accounts : [
      for role in account.project_roles : {
        account_key = account_key
        role        = role
      }
    ]
  ])
}
```

Convert the list to a map with stable keys:

```hcl
locals {
  service_account_project_role_map = {
    for assignment in local.service_account_project_roles :
    "${assignment.account_key}.${assignment.role}" => assignment
  }
}
```

Expected conceptual output:

```hcl
{
  "web.roles/logging.logWriter" = {
    account_key = "web"
    role        = "roles/logging.logWriter"
  }

  "api.roles/secretmanager.secretAccessor" = {
    account_key = "api"
    role        = "roles/secretmanager.secretAccessor"
  }
}
```

Create IAM memberships:

```hcl
resource "google_project_iam_member" "service_account_roles" {
  for_each = local.service_account_project_role_map

  project = var.project_id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.application[each.value.account_key].email}"
}
```

The reference to the service-account email creates an implicit dependency.

---

# Iteration 4: Add IAM Boundaries

Add one category at a time:

```text
1. Existing user, group, and service-account project roles
2. Service-account impersonation
3. Custom role
4. Custom-role assignment
5. Bucket-level IAM
6. Conditional IAM
```

After each category, run:

```bash
terraform fmt -check -recursive
terraform validate
terraform plan
```

Do not add all categories before running another plan.

---

# Iteration 5: Extract Reusable Modules

Extract modules only after the flat configuration works.

---

## Module 1: `service-account`

### Inputs

```text
project_id
account_id
display_name
description
disabled
```

### Resource

```text
google_service_account
```

### Outputs

```text
email
name
unique_id
member
```

Example member output:

```hcl
output "member" {
  description = "IAM member string for the service account"
  value       = "serviceAccount:${google_service_account.this.email}"
}
```

---

## Module 2: `project-iam`

### Inputs

```text
project_id
iam_memberships
```

Each membership must contain:

```text
role
member
optional condition
```

Suggested type:

```hcl
variable "iam_memberships" {
  description = "Project IAM member assignments"

  type = map(object({
    role   = string
    member = string

    condition = optional(object({
      title       = string
      description = optional(string)
      expression  = string
    }))
  }))
}
```

### Resource

```text
google_project_iam_member
```

### Outputs

```text
Managed project IAM membership keys
```

---

## Module 3: `service-account-iam`

### Inputs

```text
service_account_name
impersonators
```

Each impersonator contains:

```text
member
role
```

### Resource

```text
google_service_account_iam_member
```

### Outputs

```text
Managed impersonation assignment keys
```

---

## Module 4: `custom-role`

### Inputs

```text
project_id
role_id
title
description
permissions
stage
```

### Resource

```text
google_project_iam_custom_role
```

### Outputs

```text
role_id
role_name
```

---

## Module 5: `bucket-iam`

### Inputs

```text
bucket_name
iam_memberships
```

### Resource

```text
google_storage_bucket_iam_member
```

### Outputs

```text
Managed bucket IAM membership keys
```

Create the bucket in the environment root module and let the bucket-IAM module manage only the bucket IAM memberships.

---

# Iteration 6: Use `for_each` on Modules

Do not write:

```hcl
module "web_service_account" {
  source = "../../modules/service-account"
}

module "api_service_account" {
  source = "../../modules/service-account"
}

module "analytics_service_account" {
  source = "../../modules/service-account"
}
```

Use one module block:

```hcl
module "service_accounts" {
  source   = "../../modules/service-account"
  for_each = var.service_accounts

  project_id   = var.project_id
  account_id   = "${each.key}-${var.environment}"
  display_name = each.value.display_name
  description  = try(each.value.description, null)
}
```

Module instances are addressed as:

```text
module.service_accounts["web"]
module.service_accounts["api"]
module.service_accounts["analytics"]
```

Reference module outputs:

```hcl
module.service_accounts["web"].email
```

Or:

```hcl
module.service_accounts[each.value.account_key].member
```

---

# 9. Root Module Coding Order

Inside `environments/dev`, code in this order:

```text
1. versions.tf
2. providers.tf
3. variables.tf
4. terraform.tfvars
5. Service-account module calls
6. Custom-role module calls
7. Locals that normalize IAM data
8. Project-IAM module calls
9. Service-account-IAM module calls
10. Bucket resource
11. Bucket-IAM module calls
12. outputs.tf
13. Backend migration
```

Dependency graph:

```text
Inputs
  │
  ├── Service-account modules
  │        │
  │        ├── Project IAM memberships
  │        ├── Service-account impersonation
  │        └── Bucket IAM memberships
  │
  ├── Custom-role modules
  │        │
  │        └── Custom-role memberships
  │
  └── Bucket
           │
           └── Bucket IAM memberships
```

Do not add `depends_on` only to control ordering.

Terraform can infer dependencies when one resource references another resource or module output.

Use explicit `depends_on` only when a real dependency exists but cannot be expressed using a value reference.

---

# 10. Suggested Final Input Design

```hcl
variable "service_accounts" {
  description = "Application service accounts and their access requirements"

  type = map(object({
    display_name  = string
    description   = optional(string)
    project_roles = set(string)

    impersonators = optional(map(object({
      member = string
      role   = optional(string, "roles/iam.serviceAccountTokenCreator")
    })), {})
  }))
}
```

Example:

```hcl
service_accounts = {
  web = {
    display_name = "Web application identity"
    description  = "Runs the web workload"

    project_roles = [
      "roles/logging.logWriter",
      "roles/monitoring.metricWriter"
    ]

    impersonators = {
      developer = {
        member = "user:replace-with-your-email@example.com"
      }
    }
  }

  api = {
    display_name = "API application identity"
    description  = "Runs the API workload"

    project_roles = [
      "roles/logging.logWriter",
      "roles/secretmanager.secretAccessor"
    ]

    impersonators = {}
  }

  analytics = {
    display_name = "Analytics workload identity"
    description  = "Runs analytics workloads"

    project_roles = [
      "roles/bigquery.jobUser",
      "roles/bigquery.dataViewer"
    ]

    impersonators = {}
  }
}
```

---

# 11. Variable Validation Requirements

## Validate environment

Allow only:

```text
dev
test
prod
```

Example:

```hcl
variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition = contains(
      ["dev", "test", "prod"],
      var.environment
    )

    error_message = "Environment must be dev, test, or prod."
  }
}
```

---

## Validate service-account keys

Require lowercase logical names:

```hcl
validation {
  condition = alltrue([
    for key in keys(var.service_accounts) :
    can(regex("^[a-z][a-z0-9-]*$", key))
  ])

  error_message = "Service-account keys must use lowercase letters, numbers, and hyphens."
}
```

Also ensure that the final account ID stays within the supported service-account naming length after adding the environment.

---

## Validate project roles

The final production-style module should reject broad basic roles:

```text
roles/owner
roles/editor
roles/viewer
```

Example concept:

```hcl
locals {
  prohibited_basic_roles = toset([
    "roles/owner",
    "roles/editor",
    "roles/viewer"
  ])
}
```

For an early demonstration, you may temporarily use `roles/viewer`, but remove it before considering the capstone complete.

---

## Validate principal prefixes

Accept common IAM principal formats:

```text
user:
group:
serviceAccount:
domain:
```

Example concept:

```hcl
validation {
  condition = alltrue([
    for assignment in values(var.iam_memberships) :
    anytrue([
      startswith(assignment.member, "user:"),
      startswith(assignment.member, "group:"),
      startswith(assignment.member, "serviceAccount:"),
      startswith(assignment.member, "domain:")
    ])
  ])

  error_message = "IAM members must include a supported principal prefix."
}
```

Do not try to validate every possible GCP principal format using one enormous regular expression.

---

# 12. IAM Resource Selection

## `google_project_iam_member`

Manages one role and one principal relationship.

```text
Scope:
One member on one role

Behavior:
Non-authoritative
```

Use this as the default for the shared practice project.

---

## `google_project_iam_binding`

Manages all members for one project role.

```text
Scope:
All members for one role

Behavior:
Authoritative for that role
```

Use only when your Terraform configuration should own the complete membership list for that role.

---

## `google_project_iam_policy`

Manages the entire project IAM policy.

```text
Scope:
Complete project policy

Behavior:
Fully authoritative
```

Do not use this in the capstone project.

Incorrect usage can remove existing IAM access and potentially lock users out.

---

## Important conflict rule

Do not use IAM member and IAM binding resources to manage the same role.

Bad example:

```text
google_project_iam_binding
    manages roles/logging.viewer

google_project_iam_member
    also manages roles/logging.viewer
```

These resources can fight over the same policy membership.

---

# 13. Security Rules

Follow these rules throughout the lab:

```text
Do not grant Owner.
Do not grant Editor in the final design.
Do not create service-account keys.
Do not commit credentials.
Do not commit real terraform.tfvars files.
Do not modify Terraform state manually.
Do not manage the complete project IAM policy.
Do not mix IAM member and binding resources for the same role.
Do not grant project-level access when resource-level access is sufficient.
Do not run apply without reviewing the plan.
Do not run destroy without reviewing a destroy plan.
```

Use Application Default Credentials for local practice:

```bash
gcloud auth application-default login
```

Do not download service-account keys for this lab.

---

# 14. `.gitignore`

Create:

```gitignore
.terraform/
*.tfstate
*.tfstate.*
*.tfplan
*.tfvars
*.tfvars.json
crash.log
crash.*.log
override.tf
override.tf.json
*_override.tf
*_override.tf.json
```

Do not ignore:

```text
.terraform.lock.hcl
```

Commit:

```text
terraform.tfvars.example
```

Do not commit:

```text
terraform.tfvars
```

---

# 15. Remote State Challenge

After the local-state configuration works, create a separate bootstrap configuration.

## Why use bootstrap?

Terraform cannot use a GCS backend bucket until the bucket already exists.

Workflow:

```text
bootstrap/
    ↓
Create state bucket
    ↓
Configure environments/dev/backend.tf
    ↓
Migrate local state
```

Example backend:

```hcl
terraform {
  backend "gcs" {
    bucket = "YOUR-TERRAFORM-STATE-BUCKET"
    prefix = "iam-capstone/dev"
  }
}
```

Production prefix:

```text
iam-capstone/prod
```

Migrate state:

```bash
terraform init -migrate-state
```

Important concept:

```text
Backend configuration cannot normally use Terraform input variables because backend initialization occurs before normal variable evaluation.
```

---

# 16. Import Challenge

Create one disposable service account manually:

```text
existing-iam-lab
```

Then:

1. Write the matching Terraform resource.
2. Add an import block.
3. Run `terraform plan`.
4. Run `terraform apply`.
5. Adjust the resource configuration until the plan is clean.
6. Document the import.
7. Remove the temporary import block if appropriate.

Conceptual example:

```hcl
import {
  to = google_service_account.existing
  id = "projects/PROJECT_ID/serviceAccounts/ACCOUNT_EMAIL"
}
```

Success does not mean only:

```text
Import completed.
```

The actual success condition is:

```text
Terraform plan shows no unexpected update or replacement.
```

Do not practice imports using an important existing service account.

---

# 17. Refactoring Challenge with `moved`

Initially create:

```hcl
resource "google_service_account" "web" {
  project      = var.project_id
  account_id   = "web-dev"
  display_name = "Web Development Service Account"
}
```

Later refactor it into:

```hcl
module "service_accounts" {
  source   = "../../modules/service-account"
  for_each = var.service_accounts

  # Module inputs
}
```

Without state migration, Terraform may plan:

```text
Destroy old service account
Create new service account
```

Use a `moved` block to map the old state address to the new state address.

Conceptual structure:

```hcl
moved {
  from = google_service_account.web
  to   = module.service_accounts["web"].google_service_account.this
}
```

Use the actual resource addresses from your module.

Success criteria:

```text
No service-account replacement
No IAM loss
No destructive plan
```

This demonstrates that Terraform tracks resource addresses, not only GCP resource names.

---

# 18. Drift Detection Challenge

After applying the lab, test drift.

## Scenario 1: Add an unmanaged IAM member manually

1. Add a new IAM membership outside Terraform.
2. Run `terraform plan`.
3. Observe whether Terraform removes it.
4. Explain the result based on the IAM resource type.

With `google_project_iam_member`, unrelated members for the same role should generally be preserved because the resource manages one member-role relationship.

---

## Scenario 2: Modify a Terraform-managed IAM membership

1. Change or remove a Terraform-managed membership outside Terraform.
2. Run `terraform plan`.
3. Observe the proposed correction.
4. Apply the plan to restore the declared configuration.

---

## Scenario 3: Delete a service account manually

1. Delete one disposable service account outside Terraform.
2. Run `terraform plan`.
3. Observe whether Terraform plans to recreate it.
4. Review the effects on associated IAM memberships.

---

# 19. Failure Scenarios

A strong Terraform lab should include intentional failure testing.

---

## Test 1: Duplicate role

Add the same role twice.

Expected learning:

```text
set(string) removes duplicate values.
```

---

## Test 2: Remove one role

Remove a role from one service account.

Expected plan:

```text
Destroy one IAM membership
Do not destroy the service account
```

Predict the plan before running it.

---

## Test 3: Rename a `for_each` key

Change:

```text
web
```

to:

```text
frontend
```

Expected learning:

```text
for_each keys are part of resource identity.
```

Terraform may treat this as deleting one instance and creating another unless state is moved.

---

## Test 4: Change the display name

Expected result:

```text
In-place update
```

---

## Test 5: Change the account ID

Change:

```text
web-dev
```

to:

```text
frontend-dev
```

Expected result:

```text
Service-account replacement may be required.
```

Review all IAM relationships that depend on the service-account email.

---

## Test 6: Invalid member prefix

Use:

```text
developer@example.com
```

instead of:

```text
user:developer@example.com
```

Expected result:

```text
Variable validation fails before apply.
```

---

## Test 7: Invalid IAM condition

Use an invalid expression.

Observe whether the error occurs during:

```text
terraform validate
terraform plan
terraform apply
```

Explain why it occurred at that stage.

---

## Test 8: Remove a service account from the input map

Remove:

```text
analytics
```

Predict all planned changes.

Expected changes may include:

```text
Delete analytics service account
Delete its project IAM memberships
Delete its bucket IAM memberships
Delete its impersonation permissions
Update outputs
```

---

## Test 9: Manual deletion

Delete one service account manually and run:

```bash
terraform plan
```

Analyze the proposed recovery.

---

## Test 10: Authoritative resource conflict

Research and explain what would happen if these resources managed overlapping IAM policy areas:

```text
google_project_iam_policy
google_project_iam_binding
google_project_iam_member
```

Do not test complete-policy replacement in a shared or important project.

---

# 20. Required Outputs

Return service-account information as maps.

Example:

```hcl
output "service_accounts" {
  description = "Created application service accounts"

  value = {
    for key, service_account in module.service_accounts :
    key => {
      email     = service_account.email
      name      = service_account.name
      unique_id = service_account.unique_id
    }
  }
}
```

Expected shape:

```hcl
service_accounts = {
  web = {
    email     = "web-dev@example-project.iam.gserviceaccount.com"
    name      = "projects/example-project/serviceAccounts/web-dev@example-project.iam.gserviceaccount.com"
    unique_id = "..."
  }

  api = {
    email     = "api-dev@example-project.iam.gserviceaccount.com"
    name      = "projects/example-project/serviceAccounts/api-dev@example-project.iam.gserviceaccount.com"
    unique_id = "..."
  }
}
```

Also output:

```text
Environment
Service-account emails
Custom-role names
Project IAM membership keys
Service-account impersonation keys
Bucket name
Bucket IAM membership keys
```

A service-account email is an identifier, not a secret.

Do not mark every output as sensitive without a valid reason.

---

# 21. Terraform Workflow

Use this workflow after every meaningful change.

```bash
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform apply tfplan
```

Inspect outputs:

```bash
terraform output
```

Inspect state:

```bash
terraform state list
```

Inspect complete state information:

```bash
terraform show
```

Create a destroy plan:

```bash
terraform plan -destroy -out=destroy.tfplan
```

Review it:

```bash
terraform show destroy.tfplan
```

Apply the reviewed destroy plan:

```bash
terraform apply destroy.tfplan
```

---

# 22. GCP Verification Commands

## List service accounts

```bash
gcloud iam service-accounts list \
  --project="YOUR_PROJECT_ID"
```

## Inspect project IAM

```bash
gcloud projects get-iam-policy "YOUR_PROJECT_ID" \
  --format="table(bindings.role,bindings.members)"
```

## Inspect one service account's IAM policy

```bash
gcloud iam service-accounts get-iam-policy \
  "SERVICE_ACCOUNT_EMAIL" \
  --project="YOUR_PROJECT_ID"
```

## Describe the lab bucket

```bash
gcloud storage buckets describe \
  "gs://YOUR_BUCKET_NAME"
```

## Inspect bucket IAM

```bash
gcloud storage buckets get-iam-policy \
  "gs://YOUR_BUCKET_NAME"
```

## Test service-account impersonation

```bash
gcloud auth print-access-token \
  --impersonate-service-account="SERVICE_ACCOUNT_EMAIL"
```

Run impersonation testing only against disposable lab service accounts.

---

# 23. Acceptance Criteria

Do not consider the lab complete until all requirements below are satisfied.

## Functionality

- [ ] Three service accounts are created from one input map.
- [ ] Service-account names include the environment.
- [ ] Each service account receives multiple project-level roles.
- [ ] Existing users can receive project roles.
- [ ] Existing groups are supported by the input design.
- [ ] Existing service accounts can receive project roles.
- [ ] At least one principal can impersonate a service account.
- [ ] At least one custom role is created.
- [ ] The custom role is assigned to a principal.
- [ ] One Cloud Storage bucket is created.
- [ ] Bucket-level IAM is assigned.
- [ ] At least one conditional temporary permission exists.
- [ ] Development and production use the same modules.
- [ ] Development and production use different input values.

## Terraform Design

- [ ] Service accounts are created with `for_each`.
- [ ] IAM memberships are created with `for_each`.
- [ ] Modules are called with `for_each`.
- [ ] No repeated service-account resource blocks exist.
- [ ] No repeated project-IAM block exists for every role assignment.
- [ ] Every `for_each` uses stable and understandable keys.
- [ ] Nested IAM data is normalized with locals.
- [ ] Module variables include descriptions.
- [ ] Module outputs include descriptions.
- [ ] Outputs are returned as maps.
- [ ] Provider versions are constrained.
- [ ] `.terraform.lock.hcl` is committed.
- [ ] Real `.tfvars` files are ignored.
- [ ] Example `.tfvars` files are committed.
- [ ] Remote state uses separate environment prefixes.

## Security

- [ ] No Owner role is granted.
- [ ] No Editor role exists in the final design.
- [ ] No service-account keys are created.
- [ ] No credentials are committed.
- [ ] The complete project IAM policy is not replaced.
- [ ] IAM member and binding resources do not overlap on the same role.
- [ ] Resource-level access is used when project-level access is unnecessary.
- [ ] Every apply uses a reviewed plan.
- [ ] Every destroy uses a reviewed destroy plan.

## Operations

- [ ] One disposable existing service account is imported.
- [ ] One Terraform resource is refactored without recreation.
- [ ] One drift scenario is created and explained.
- [ ] One IAM role is removed and the plan is predicted correctly.
- [ ] One `for_each` key rename is tested.
- [ ] Development resources are destroyed without affecting unrelated IAM.

---

# 24. Terraform Interview Questions

After completing the lab, answer these without looking at notes.

## General Terraform

1. How does Terraform determine resource creation order?
2. Does Terraform execute `main.tf` before `outputs.tf`?
3. Why use `for_each` instead of `count` for named identities?
4. Why must `for_each` keys be known during planning?
5. Why flatten a nested IAM map?
6. What makes a good `for_each` key?
7. What happens when a `for_each` key changes?
8. How do module outputs behave when the module uses `for_each`?
9. When should explicit `depends_on` be used?
10. What is the difference between local and remote state?
11. Why should `.terraform.lock.hcl` be committed?
12. How do you migrate local state to GCS?
13. How do you import an existing resource?
14. What does a `moved` block solve?
15. What is infrastructure drift?
16. How do variable validation, preconditions, postconditions, and checks differ?
17. Why can backend configuration not normally use variables?
18. What information is stored in Terraform state?
19. Why must Terraform state be protected?
20. How do you safely refactor a resource into a module?
21. What is the difference between a list, set, and map?
22. Why use a set for IAM roles?
23. What is an implicit dependency?
24. What is an explicit dependency?
25. What happens when an item is removed from a `for_each` map?

---

# 25. GCP IAM Interview Questions

1. What is a principal?
2. What is a permission?
3. What is a role?
4. What is an IAM policy?
5. What is an IAM binding?
6. What is the difference between predefined, basic, and custom roles?
7. Why should Owner and Editor be avoided?
8. What is least privilege?
9. When should access be granted at the project level?
10. When should access be resource-specific?
11. What is a service account?
12. How is a service account both a principal and a resource?
13. What is service-account impersonation?
14. What is the difference between Service Account User and Token Creator?
15. Why should service-account keys be avoided?
16. What is an IAM Condition?
17. How would you implement temporary access?
18. What is the difference between project IAM and bucket IAM?
19. How would you grant access to only one bucket?
20. What happens when a service account is deleted and recreated?
21. What is an authoritative IAM resource?
22. What is a non-authoritative IAM resource?
23. Why can IAM binding and IAM member resources conflict?
24. When should a custom role be used?
25. What risks come with service-account impersonation?
26. Why is a Google group generally preferred over individual user assignments?
27. How would you investigate IAM drift?
28. How would you safely remove access?
29. What is the difference between role assignment and service-account impersonation?
30. Why should IAM be managed at the smallest appropriate scope?

---

# 26. Suggested Practice Schedule

## Day 1

Build:

```text
One service account
One project role
One output
```

Practice:

```text
Provider
Variable
Resource
Reference
Output
Plan
Apply
Destroy
```

## Day 2

Build:

```text
Multiple service accounts
Multiple project roles
```

Practice:

```text
map(object)
set(string)
for_each
each.key
each.value
```

## Day 3

Build:

```text
Nested role assignments
IAM data normalization
```

Practice:

```text
flatten()
Nested for expressions
Stable map keys
```

## Day 4

Build:

```text
Existing-principal access
Service-account impersonation
```

Practice:

```text
Project IAM
Service-account IAM
Principal formats
```

## Day 5

Build:

```text
Custom role
Bucket-level IAM
```

Practice:

```text
Custom permissions
Resource-level access
Least privilege
```

## Day 6

Build:

```text
IAM Conditions
Variable validation
Dynamic condition blocks
```

## Day 7

Refactor into modules:

```text
service-account
project-iam
service-account-iam
custom-role
bucket-iam
```

## Day 8

Create:

```text
dev
prod
Remote GCS state
```

## Day 9

Practice:

```text
Import
Moved blocks
Drift detection
State inspection
```

## Day 10

Rebuild the development environment from a blank folder using only the requirements.

Explain every:

```text
Variable
Local
Resource
Module
for_each key
Dependency
Output
Plan action
IAM decision
```

---

# 27. Universal Implementation Loop

For every new IAM requirement, use this process:

```text
Read the requirement
        ↓
Identify existing objects
        ↓
Identify objects Terraform must create
        ↓
Choose the IAM scope
        ↓
Choose member, binding, or policy
        ↓
Design the input variable
        ↓
Create one working instance
        ↓
Generalize using for_each
        ↓
Normalize nested data using locals
        ↓
Review the Terraform plan
        ↓
Extract reusable logic into a module
        ↓
Test update, removal, drift, and destroy
```

Use this shorter memory model:

```text
Configure
    ↓
Input
    ↓
Create
    ↓
Connect
    ↓
Output
    ↓
Generalize
    ↓
Modularize
    ↓
Test lifecycle
```

---

# 28. Core Terraform Development Principle

Do not begin with a complicated reusable module.

Use this sequence:

```text
Make one case work
    ↓
Make multiple cases work
    ↓
Normalize the input
    ↓
Extract a reusable module
    ↓
Test changes and deletion
    ↓
Test drift and import
    ↓
Rebuild from a blank folder
```

The ability to rebuild and explain the solution is more valuable than memorizing the final code.

---

# 29. Final Mastery Exercise

After completing the lab:

1. Review every resource and IAM assignment.
2. Create and review a destroy plan.
3. Destroy only the development lab.
4. Confirm unrelated project IAM remains unchanged.
5. Keep the requirements document.
6. Move the completed code to another location.
7. Create a new empty directory.
8. Rebuild the project without copying the original code.
9. Compare your new design with the original.
10. Explain the differences and improvements.

You should be able to explain:

```text
Why each IAM assignment exists
Why each IAM scope was selected
Why member resources were selected
Why each module boundary exists
Why each for_each key is stable
How dependencies are created
How state tracks the resources
How to safely change access
How to identify destructive changes
How to detect and correct drift
How to import existing IAM resources
How to refactor without recreation
```

If you can rebuild the project and explain all these decisions, you have developed practical confidence with Terraform and GCP IAM.