# terraform apply

`terraform apply` executes the actions proposed by Terraform and modifies real infrastructure.
- This is the command that actually creates, updates, or destroys infrastructure.

## What Happens During apply?

Terraform performs the following steps:

```text
Read Configuration
        ↓
Read State
        ↓
Query Provider
        ↓
Generate Plan
        ↓
Ask For Approval
        ↓
Execute Changes
        ↓
Update State
```

---

## Basic Usage

```bash
terraform apply

# Plan: 2 to add, 1 to change, 0 to destroy.

#Terraform asks:
# Do you want to perform these actions?
# Enter a value:
# to continue.
```
- Auto Approval. Skip confirmation prompt. Terraform immediately executes changes.

```bash
terraform apply -auto-approve
```
---

## Resource Creation Order
Terraform automatically determines dependencies.

```text
VPC
 ↓
Subnet
 ↓
VM

# Terraform creates:
VPC First
Subnet Second
VM Third
```

###  Parallel Execution
Independent resources may be created simultaneously. Making **Faster Deployments**

```text
Bucket A

Bucket B

Bucket C
```
Terraform may create them in parallel.

---

### Apply with Variables

Provide variables directly:

```bash
terraform apply -var="environment=dev"

# Using tfvars:
terraform apply -var-file="dev.tfvars"
```

---

## Apply Failure

When the `terraform apply` fails halfway through, ***Terraform does not roll back changes***. Because Terraform is declarative but not transactional, there is no automatic *undo* funciton. 
- Instead, It halts execution immediately, saves its programss and Exits

1. Resources created before the error occurred remain live in your cloud provider. Resources that hadn't been reached yet do not exist.
2. Terraform updates the state file with any successfully created or modified resources up to the point of failure.
3. Terraform automatically releases the state lock so that future commands can run
4. Any resources that depended on the failed resource are skipped entirely.

### Common Reasons for Failure
- **API Rate Limits**: Cloud providers throttling the deployment.
- **Permission Denied**: The IAM role running Terraform lacks the credentials to create a specific resource.
- **Resource Already Exists**: Terraform tries to create a resource, but an identical one already exists outside of Terraform's management.
- **Configuration / Parameter Errors**: Passing invalid arguments that only the cloud provider's API catches during creation (e.g., an unavailable instance size

### Handling Failures

Rolling back would mean destroying every resource that was successfully created during the failed apply. In practice, this is often worse than the partial state. A VPC with a subnet but no instances is harmless. Destroying the VPC and subnet to "roll back" would also destroy any other resources you'd attached to them in the meantime, or resources from other Terraform configurations sharing the same VPC.

Terraform's design accepts partial failure as a normal operating condition and gives you tools to move forward from it rather than backward. The general philosophy of Terraform is to roll forward, not backward

1. Start with `terraform plan`. It will compare your configuration against the state file and show you exactly what still needs to happen:
2. The output will show the failed resource as needing creation, along with any downstream resources that were skipped. Everything that was successfully created should show no changes, since the state already reflects their existence.
3. If the plan looks strange or shows resources being recreated that you know exist, your state may be out of sync. Running `terraform apply -refresh-only` will update state to match actual infrastructure without making changes
4. Most of the time, recovery is straightforward. 
    - Fix whatever caused the original failure (correct the configuration, switch availability zones, request a quota increase) 
    - Run `terraform apply` again. Terraform will pick up where it left off, creating only the resources that are missing from state.

---

## Common Flags

1. Auto Approve Skip confirmation. `terraform apply -auto-approve`
2. Variable `terraform apply -var="project_id=my-project"`
3. Variable File `terraform apply -var-file="prod.tfvars"`
4. Replace Resource `terraform apply -replace=google_compute_instance.web`
5. Target Resource: Apply only selected resource. `terraform apply -target=google_storage_bucket.logs`
6. Refresh Only: Updates state only and No infrastructure changes. `terraform apply -refresh-only`

---

### CI/CD Workflow

Pipeline: Widely used in production environments.

```text
terraform init
        ↓
terraform validate
        ↓
terraform plan -out=tfplan
        ↓
Manual Approval
        ↓
terraform apply tfplan
```

***Interview Keywords:***

```text
Execution
Infrastructure Provisioning
State Update
Approval Step
Resource Creation
Resource Modification
Deployment
```