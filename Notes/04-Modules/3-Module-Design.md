# Module Design

Module Design is the practice of creating Terraform modules that are:
- Reusable
- Maintainable
- Flexible
- Simple
- Predictable

**Single Responsibility Principle `One module = One purpose`**

## Module Structure

Recommended:

```text
modules/

└── network/
    │
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── versions.tf
    └── README.md
```

---

# Good Module Interface

The module interface consists of:

```text
Inputs
Outputs
```

Think:

```text
Public API
```

for your module.

---

# Example

Inputs:

```hcl
variable "vpc_name" {}
variable "region" {}
```

Outputs:

```hcl
output "network_id" {}
```

Everything else should remain internal.

---

# Avoid Hardcoding

Bad:

```hcl
resource "google_compute_network" "main" {
  name = "prod-vpc"
}
```

Reusable?

```text
No
```

---

Good:

```hcl
resource "google_compute_network" "main" {
  name = var.vpc_name
}
```

Reusable?

```text
Yes
```

---

# Use Variables For Configuration

Instead of:

```hcl
machine_type = "e2-standard-4"
```

Use:

```hcl
machine_type = var.machine_type
```

Then:

```text
Dev  → e2-medium

Prod → e2-standard-4
```

---

# Provide Sensible Defaults

Good:

```hcl
variable "region" {

  type    = string
  default = "us-central1"

}
```

Users can override when needed.

---

# Keep Required Inputs Minimal

Bad:

```text
25 Required Variables
```

Hard to use.

---

Better:

```text
3 Required Variables
5 Optional Variables
```

Simple interface.

---

# Use Strong Typing

Bad:

```hcl
variable "config" {}
```

---

Good:

```hcl
variable "config" {

  type = object({

    machine_type = string
    disk_size    = number

  })

}
```

Benefits:

```text
Validation
Safety
Documentation
```

---

# Add Validation

Example:

```hcl
variable "environment" {

  type = string

  validation {

    condition =
      contains(
        ["dev","test","prod"],
        var.environment
      )

    error_message =
      "Environment must be dev, test, or prod."

  }

}
```

---

# Expose Useful Outputs

Good outputs:

```text
IDs
Names
URLs
Emails
IP Addresses
```

---

Example:

```hcl
output "network_id" {
  value = google_compute_network.main.id
}
```

---

# Don't Expose Everything

Bad:

```text
50 Outputs
```

Most consumers won't need them.

Expose:

```text
Only Useful Values
```

---

# Use Meaningful Names

Bad:

```hcl
variable "x" {}
```

```hcl
variable "temp" {}
```

---

Good:

```hcl
variable "project_id" {}
```

```hcl
variable "network_name" {}
```

---

# Use Locals For Internal Logic

Bad:

```hcl
resource "google_storage_bucket" "logs" {

  name =
  "${var.environment}-${var.application}-logs"

}
```

repeated throughout module.

---

Good:

```hcl
locals {

  bucket_name =
    "${var.environment}-${var.application}-logs"

}
```

Use:

```hcl
local.bucket_name
```

---

# Module Encapsulation

Consumers should not know module internals.

Bad:

```text
Parent Module
      ↓
Direct Resource References
```

---

Good:

```text
Parent Module
      ↓
Inputs & Outputs Only
```

---

# Version Your Modules

For shared modules:

```hcl
module "network" {

  source =
    "terraform-google-modules/network/google"

  version = "~> 10.0"

}
```

Benefits:

```text
Repeatable Deployments
Safe Upgrades
```

---

# Documentation Matters

Every module should explain:

```text
Purpose
Inputs
Outputs
Examples
Requirements
```

---

# README Example

```text
Module Name

Purpose

Required Inputs

Optional Inputs

Outputs

Usage Example
```

---

# Environment Agnostic Design

Avoid:

```hcl
name = "prod-vpc"
```

---

Use:

```hcl
name =
"${var.environment}-vpc"
```

Supports:

```text
dev-vpc

test-vpc

prod-vpc
```

---

# Dependency Management

Bad:

```text
Module A Depends On
Module B Depends On
Module C Depends On
```

Complex relationships.

---

Good:

```text
Loose Coupling
```

Communication through:

```text
Outputs
Inputs
```

---

# Module Chaining

Example:

```text
Network Module
        ↓
network_id
        ↓
GKE Module
```

Root Module:

```hcl
module "gke" {

  network_id =
    module.network.network_id

}
```

This is the preferred design.

---

# Small Modules vs Large Modules

## Small Modules

Examples:

```text
network

gke

storage

iam
```

Benefits:

```text
Reusable
Easy Testing
Easy Maintenance
```

---

## Large Modules

Example:

```text
Everything In One Module
```

Problems:

```text
Hard To Reuse
Hard To Maintain
Difficult Testing
```

---

# Real GCP Example

## Network Module

Creates:

```text
VPC
Subnets
Routes
```

Outputs:

```text
network_id
subnet_ids
```

---

## GKE Module

Inputs:

```text
network_id
subnet_id
```

Creates:

```text
GKE Cluster
```

Modules remain independent.

---

# Module Layering Pattern

Common production structure:

```text
Root Module
      ↓

Network Module
      ↓

GKE Module
      ↓

Application Module
```

Communication:

```text
Outputs
      ↓
Inputs
```

---

# Common Design Mistakes

## Too Many Inputs

Bad:

```text
40 Variables
```

Complex to use.

---

## Too Many Outputs

Bad:

```text
100 Outputs
```

Hard to maintain.

---

## Hardcoded Values

Bad:

```hcl
region = "us-central1"
```

inside module.

---

## Environment Specific Logic

Bad:

```hcl
if prod then ...
```

everywhere.

Keep environment differences in inputs.

---

## Massive Modules

Avoid creating:

```text
One Module To Rule Them All
```

---

# Best Practices

### ✅ One Responsibility Per Module

```text
Network
Storage
IAM
GKE
```

---

### ✅ Use Variables For Configuration

Improve reuse.

---

### ✅ Expose Useful Outputs

Avoid excessive outputs.

---

### ✅ Add Validation

Catch errors early.

---

### ✅ Document Everything

README is essential.

---

### ✅ Use Naming Conventions

Consistent naming across modules.

---

### ✅ Prefer Small Focused Modules

Easier to maintain.

---

### ✅ Keep Modules Environment Agnostic

Support:

```text
dev
test
prod
```

through inputs.

---

# Interview Questions

## What makes a good Terraform module?

A module that is:

```text
Reusable
Maintainable
Flexible
Well Documented
```

---

## Why avoid hardcoded values?

They reduce reusability and flexibility.

---

## Why should modules be small?

Small modules are easier to understand, test, and reuse.

---

## What is module encapsulation?

Modules should expose only inputs and outputs while hiding internal implementation details.

---

## How should modules communicate?

Using:

```text
Outputs
      ↓
Inputs
```

---

## What is the Single Responsibility Principle in Terraform?

A module should have one clear purpose.

Example:

```text
Network Module
```

instead of:

```text
Network + IAM + GKE + Storage
```

---

## Why document modules?

To make them easier for consumers to understand and use.

---

# Quick Revision

Good Module Design:

```text
Reusable
Small
Focused
Flexible
Documented
```

Core Rules:

```text
One Responsibility

Use Inputs

Expose Outputs

Avoid Hardcoding

Use Validation

Version Modules
```

Recommended Structure:

```text
main.tf
variables.tf
outputs.tf
versions.tf
README.md
```

Communication:

```text
Module Outputs
       ↓
Module Inputs
```

Avoid: