# Outputs

## What are Outputs?

Outputs are values that Terraform displays after applying infrastructure. `output = results`

Terraform creates:
```text
VM
IP Address
Bucket
Database
```
Outputs allow us to expose those values.

---

## Why Use Outputs?

Without outputs:

```text
Create VM
Go to Cloud Console
Find IP Address
Copy Manually
```

With outputs:

```bash
terraform apply

#Terraform immediately displays:

web_ip = 34.123.45.67
```

Benefits:
- Quick access to resource information
- Easier automation
- Communication between modules
- Integration with CI/CD

---

## Output Syntax

```hcl
output "<NAME>" {
  value = ...
}

resource "google_storage_bucket" "logs" {
  name     = "app-logs"
  location = "US"
}

output "bucket_name" {
  value = google_storage_bucket.logs.name
}

terraform apply

Outputs: bucket_name = "app-logs"
```
---

## Referencing Resource Attributes

Outputs typically expose resource attributes.

```hcl
output "vm_id" {
  value = google_compute_instance.web.id
}

Resource: google_compute_instance.web
Attribute: id
```
---

## Common Resource Attributes

### 1. ID

```hcl
output "vm_id" {
  value = google_compute_instance.web.id
}
```

### 2. Name

```hcl
output "bucket_name" {
  value = google_storage_bucket.logs.name
}
```

### 3. Self Link

```hcl
output "bucket_url" {
  value = google_storage_bucket.logs.self_link
}
```

### 4. IP Address

```hcl
output "public_ip" {
  value = google_compute_instance.web.network_interface[0].access_config[0].nat_ip
}
```
---

## Output Description

Add documentation.

```hcl
output "bucket_name" {
  description = "Name of the application log bucket"

  value = google_storage_bucket.logs.name
}
```

---

## Sensitive Outputs

Some outputs should not be displayed.

```hcl
output "db_password" {
  value     = var.db_password
  sensitive = true
}

Output:

db_password = (sensitive value)
```
Useful for:
- Passwords
- Tokens
- Secrets
- API Keys

---

## Output Dependencies

Outputs automatically depend on referenced resources.

```hcl
output "network_id" {
  value = google_compute_network.main.id
}

Terraform knows:
Network
   ↓
Output
```
**No explicit dependency required.**

---

## Accessing Outputs

### 1. Show All Outputs

```bash
terraform output

# bucket_name = "app-logs"
# project_id  = "gcp-dev"
```

### 2. Show Specific Output

```bash
terraform output bucket_name

# app-logs
```

### 3. JSON Format

Useful for automation.

```bash
terraform output -json

{
  "bucket_name": {
    "value": "app-logs"
  }
}
```

---

## Using Outputs in Automation

Example:

```bash
BUCKET=$(terraform output -raw bucket_name)

echo $BUCKET
app-logs
```

Useful in:
- Shell Scripts
- CI/CD Pipelines
- GitHub Actions
- Cloud Build

---

## Common Use Cases

##### 1. VM Public IP

```hcl
output "public_ip" {
  value = google_compute_instance.web.network_interface[0].access_config[0].nat_ip
}
```

##### 2. Bucket Name

```hcl
output "bucket_name" {
  value = google_storage_bucket.logs.name
}
```

##### 3. Service Account Email

```hcl
output "service_account_email" {
  value = google_service_account.app.email
}
```

##### 4. GKE Cluster Name

```hcl
output "cluster_name" {
  value = google_container_cluster.main.name
}
```

##### 5. BigQuery Dataset

```hcl
output "dataset_id" {
  value = google_bigquery_dataset.analytics.dataset_id
}
```

---

## Best Practices

1. Output Only Useful Information
2. Add Descriptions
3. Mark Secrets Sensitive
4. Use Outputs for Module Communication. Outputs are the primary way modules expose information.
5. Keep Outputs in `outputs.tf`

Typical project structure:
```text
terraform/
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
└── versions.tf
```

Terraform reads outputs directly from state.

This is why: `terraform output` works even after leaving and returning to the project.

---

## Output Lifecycle

```text
Resource Created
       ↓
Terraform State Updated
       ↓
Output Evaluated
       ↓
Output Displayed
```

Whenever resources change: `terraform apply`. Outputs are recalculated.

---

## Output Dependencies

Terraform automatically tracks dependencies.

Example:

```hcl
output "vpc_id" {
  value = google_compute_network.main.id
}
```

Dependency Graph:

```text
VPC
 ↓
Output
```

Terraform ensures outputs are evaluated after the required resources exist.

