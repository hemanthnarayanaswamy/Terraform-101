# terraform destroy

`terraform destroy` removes all infrastructure managed by Terraform.

Terraform reads its state and removes the resources it manages.

Used to:
- Tear down environments
- Clean up test resources
- Remove unused infrastructure
- Avoid unnecessary cloud costs

```text
Dev Environment
      ↓
Testing Complete
      ↓
terraform destroy
      ↓
Resources Removed
```

What Gets Destroyed?
- Terraform only destroys resources tracked in state.

What Does NOT Get Destroyed?
- Manually created resources not in Terraform state.
- Terraform does not know about them.

## What Happens During destroy?

Terraform performs:

```text
Read Configuration
        ↓
Read State
        ↓
Create Destroy Plan
        ↓
Ask For Approval
        ↓
Delete Resources
        ↓
Update State
```

```bash
terraform destroy

#Terraform generates a destruction plan.
Plan: 0 to add, 0 to change, 5 to destroy.

# Do you really want to destroy all resources?
# Enter a value:
```

## Resource Destruction Order

Terraform follows dependencies.

```text
# Creation Order
VPC
 ↓
Subnet
 ↓
VM

# Destroy Order:
VM
 ↓
Subnet
 ↓
VPC
```
***Terraform automatically builds the dependency graph.***

---

### 1. Auto Approval
Skip confirmation prompt.
```bash
terraform destroy -auto-approve
```
Terraform immediately starts deleting resources.

### 2. Destroy with Variables
Terraform uses the supplied values while evaluating the configuration.
```bash
terraform destroy -var-file=dev.tfvars

terraform destroy -var="environment=dev"
```
### 3. Destroy Specific Resource
Destroy a single resource.

```bash
terraform destroy -target=google_storage_bucket.logs
```
---

## prevent_destroy

Terraform provides protection against accidental deletion.

```hcl
resource "google_sql_database_instance" "prod" {
  lifecycle {
    prevent_destroy = true
  }
}

terraform destroy
# Error: Resource cannot be destroyed.
```
Useful when handling:
- Production Databases
- Critical Storage
- Shared Resources

---

## Partial Destroy Failures

When a terraform destroy command fails, your infrastructure is left in a state of partial deletion, and your Terraform state file becomes out of sync with reality. Because Terraform executes deletions sequentially based on resource dependencies, a failure halts the process midway.

1. **Partial Resource Deletion**: Some resources will have already been successfully deleted, while others remain completely intact in your cloud environment.
2. **State File Inconsistency**: Terraform updates the state file in real-time as it successfully deletes each item. For the resources that failed to delete, they remain tracked in your state file.
3. **Dangling or "Orphaned" Dependencies**: If a parent resource was deleted but a child resource failed, you may be left with detached components (e.g., an active Network Interface attached to a subnet you are trying to delete).
4. **State Locking**: If the command crashed or timed out, the state backend may remain locked, preventing you from running any subsequent commands until it is released

### Common Reasons for Failure

1. Cloud providers won't allow Terraform to delete an AWS S3 bucket or an Azure Storage Account if it still contains objects or data
2. A resource was modified manually via the cloud console (e.g., a security group rule was attached to an EC2 instance), preventing Terraform from cleanly tearing it down
3. The configuration contains a lifecycle { prevent_destroy = true } block, which explicitly instructs Terraform to block any deletion attempts.
4. Your IAM or cloud credentials lack the specific delete permissions required for those resources.
5. Dependency Errors: Resource still in use. A dependent resource must be removed first.

---

# destroy vs state rm

1. `terraform destroy` it deletes resource and remove the resources from state. 
2. `terraform state rm` Keep Resources but remove that resource from the state. That way it is not tracked by terraform anymore.

```bash
terraform state rm google_storage_bucket.logs

#Bucket remains in GCP.
# Terraform no longer manages it.
```

### What is the safest destroy workflow?

```bash
terraform plan -destroy
terraform destroy
```

***Interview Keywords:***

```text
Infrastructure Teardown
Dependency Graph
State Management
prevent_destroy
Resource Cleanup
Environment Removal
```