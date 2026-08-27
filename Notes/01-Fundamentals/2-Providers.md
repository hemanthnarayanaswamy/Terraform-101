# Providers

## What is a Provider?

A provider is a plugin that allows Terraform to interact with an external platform.

Examples:
- Google Cloud (GCP)
- AWS
- Azure
- Kubernetes
- GitHub
- Datadog

Without a provider, Terraform does not know how to create or manage resources.

---

## How Terraform Works

```ini
Terraform Core
      |
      V
  Provider
      |
      V
Cloud API

Example:

Terraform Core
      |
      V
Google Provider
      |
      V
GCP APIs
```
Terraform generates an execution plan and the provider communicates with the cloud APIs to perform the actual operations.

---

## Why Providers Exist

Terraform is cloud-agnostic.

The same Terraform language can be used for:

- GCP
- AWS
- Azure
- Kubernetes

Only the provider changes.

---

## Provider Block

```hcl
provider "google" {
  project = "my-project"
  region  = "northamerica-northeast1"
}
```
This tells Terraform:

- Use Google Cloud
- Use project `my-project`
- Use region `northamerica-northeast1`

---

## Required Providers

Defined in the Terraform block.

```hcl
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}
```

Purpose:
- Download correct provider
- Pin versions
- Ensure consistency

```hcl
version = "~> 7.0"

>= 7.0
< 8.0
```
---

## Install Provider

```bash
terraform init
```

Terraform:
1. Reads configuration
2. Downloads provider plugins
3. Creates `.terraform/`
4. Creates `.terraform.lock.hcl`

---

## Multiple Providers

Terraform can use multiple providers in a single configuration.

```hcl
provider "google" {}

provider "kubernetes" {}
```

Possible workflow:
- Terraform creates GKE cluster in GCP
- Terraform deploys resources into that cluster

---

## Provider Authentication (GCP)

#### 1. Application Default Credentials (ADC)

```bash
gcloud auth application-default login
```
Best for local development.

#### 2. Service Account Key

```hcl
provider "google" {
  credentials = file("sa.json")
  project      = "my-project"
  region       = "us-central1"
}
```
Used in automation environments.

#### 3. Workload Identity

Recommended for production. ***Avoids managing service account keys.***

---

## Provider Alias

Allows multiple configurations of the same provider.

```hcl
provider "google" {
  project = "dev-project"
}

provider "google" {
  alias   = "prod"
  project = "prod-project"
}
```

```hcl
resource "google_storage_bucket" "logs" {
  provider = google.prod
  name     = "prod-logs"
}
```

- Multi-project deployments
- Multi-region deployments
- Shared infrastructure

---

## Common GCP Provider Resources

```hcl
google_compute_instance
google_storage_bucket
google_service_account
google_compute_network
google_sql_database_instance
google_container_cluster
google_pubsub_topic
google_bigquery_dataset

-- Provider + Resource Type
# google_compute_instance
# provider "google"
```
---

## Files Created by Providers

#### `.terraform/`

Stores downloaded provider plugins.

Do NOT edit manually.

#### `.terraform.lock.hcl`

Locks provider versions. Commit to Git.

- Reproducible builds
- Team consistency

---

## Interview Questions

### What is a provider?

A plugin that enables Terraform to communicate with external APIs and manage resources.

---

### Why do we need providers?

Terraform Core cannot directly interact with cloud platforms. Providers act as translators between Terraform configuration and cloud APIs.

---

### What happens during terraform init?

- Downloads provider plugins
- Initializes backend
- Creates `.terraform`
- Creates lock file

---

### Why pin provider versions?

To prevent unexpected behavior and breaking changes after upgrades.

---

### What is a provider alias?

A named provider configuration that allows multiple instances of the same provider.

Example:

- Dev project
- Prod project
- Multiple regions

---

### Difference Between Terraform Core and Provider

Terraform Core:
- Reads HCL
- Creates execution plan
- Manages state

Provider:
- Talks to cloud APIs
- Creates/updates resources
- Returns resource information
