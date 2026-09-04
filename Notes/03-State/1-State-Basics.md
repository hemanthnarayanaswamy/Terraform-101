# State Basics

Terraform State is Terraform's memory.

It is how Terraform keeps track of the infrastructure it manages.

Terraform cannot effectively manage infrastructure without state.

State is the Source of Truth. Terraform relies heavily on state.

State tells Terraform:
- What Exists
- What Was Created
- What Must Change
- What Must Be Deleted

Without state Terraform loses context

### Why Do We Need State?

Suppose Terraform creates a VM. VM Exists in GCP

- How does Terraform know
- which VM it created?

> State File is where all the information about the exiting infrastructure managed my terraform resides.

Terraform stores:
- Resource IDs
- Resource Attributes
- Dependencies
- Metadata

Terraform stores information like:

```text
google_storage_bucket.logs

ID: app-logs
Location: US
Project: my-project
```
---

## State File

By default Terraform uses: `terraform.tfstate`

```text
project/

├── main.tf
├── variables.tf
├── outputs.tf
└── terraform.tfstate
```

## How Terraform Uses State
State is involved in almost every Terraform command.

```text
Read Configuration
        ↓
Read State
        ↓
Query Provider
        ↓
Compare
        ↓
Generate Plan
```

```text
Terraform Code -> Desired State

Terraform State -> Known State

Cloud Resources -> Actual State
```
Terraform continuously compares all three.

---

### Local State vs Remote State

Default behavior. Stored on local machine in a File: `terraform.tfstate`. Not ideal for teams but can be used for:
- Learning
- Labs
- Personal Projects

State stored remotely. and Everyone uses the same state file.
- GCP Cloud Storage
- AWS S3
- Azure Storage
- Terraform Cloud

Why is Remote State Recommended? It Provides
- Collaboration
- Centralization
- Consistency
- Recovery

![local vs remote](https://cdn.prod.website-files.com/644656ba41efb6b601e93ca6/6735f654f915bc1341994d7c_AD_4nXe6z1VUoAbtShq57lTYkcLzV21FsHim3KWInEWWFct4QeAbAcz4_W6TmAymKNpyPBrsKTDKnjTWtlAkc0OqNWPViY2kX8_Ut3nJaa8iCwc9wMEl0qMtAybtBSxGLP3S5gKEJCED4A.png)
---

# Common State Problems

## 1. Stete File Corruption/Corrupted State
A common problem with state files is file corruption, which could be due to several reasons
State becomes invalid. The possible reasons for this are:
- Network issues during the state update process
- Manual modifications
- Software bugs.

**SOLUTION**
- *Remote State Storage*: You can put to use remote backends like AWS S3, Azure Blob Storage, or Google Cloud Storage.
- *State Backup*: You must also enable versioning on state storage to keep backups of previous state files. This allows recovery from corruption by reverting to an original or well-known state.
- *State Validation*: Use Terraform validate and Terraform plan if you want to regularly check and maintain the integrity of your state file.

> What happens if the state file is lost? **Terraform loses track of managed infrastructure and may attempt to recreate resources.**

## 2. State File Conflicts
The risk of state file conflicts increases as the number of team members working on the same Terraform configuration increases. This happens primarily due to performing simultaneous operations that modify the state file, which could lead to inconsistencies or lost changes.

- **STATE LOCKING**: State locking mechanisms will guarantee that only one operation can modify the state file at a given time. This will prevent conflicts from occurring in the first place.
- **AUTOMATED PIPELINES**: You can implement *CI/CD* pipelines to manage Terraform deployments. This will centralize state changes and consequently lessen the probability of conflicts. 

## 3. State File Security
State file security is often at risk because it carries sensitive information, such as resource configurations and credentials. If it is not properly secured, managed, or handled, it can lead to a major security breach, and the information can be exposed to unauthorized users.

- **ENCRYPTION**: You must encrypt the state file for this purpose at rest using backend-specific encryption mechanisms. 
```hcl
terraform {
  backend “s3” {
    bucket = “my-terraform-state”
    key    = “path/to/my/key”
    region = “us-west-2”
    encrypt = true
  }
}
```
- **ACCESS CONTROLS**: Implement stricter policies and access controls to your state file. GCP `IAM` policies to restrict and limit access to authorized users only. 
- **Sensitive Data Masking**: With the help of the `sensitive` *attribute* in Terraform, you can avoid and prevent sensitive data leakage and exposure in the output.
```hcl
output “db_password” {
  value     = aws_db_instance.default.password
  sensitive = true
}
```

## 4. Handling Large State Files
With the growing infrastructure and its needs, the state file also expands or grows. These large state files tend to slow down the system and Terraform operations, rendering them inefficient and ineffective.

- **State File Partitioning**: You can try splitting the infrastructure into multiple Terraform configuraitons to manage them independently. 
- **Modules and Workspaces**: You can also use Terraform modules and workspaces for managing different environments and components individually.
- **Selective State Retrieval**: Terraform state commands help you target specific resources and minimize the amount or volume of state data loaded during operations.

## 5. Lack of Automated Testing
If you don’t perform adequate testing, misconfigurations, logical falws, and security violations can have serious implication during deployment.

- **FUNCTIONAL TESTS**: Perform functional tests with `Terratest` in cloud proivder to validate your configurations before the production phase. 
- **Automate Security**:Use automated security checks to make your infrastructure compliant with regulations like HIPAA, GDPR, and more. This way you won’t have to rewrite modules from scratch.  

The native [Terraform Test Framework](https://developer.hashicorp.com/terraform/language/tests) (introduced in `v1.6/v1.7`) has largely replaced the need for external programming-language-based tools by allowing unit and integration tests to be written directly in HCL.
- `terraform test`: Executes functional assertions written in `.tftest.hcl` files.
- **Unit Tests** (command = plan): Runs assertions against a generated plan file. It does not touch cloud APIs, ensuring zero cost and rapid execution speed.
- **Provider Mocking**: Introduced in Terraform v1.7, this lets you simulate provider responses locally. You can validate module outputs and dynamic logic without real cloud accounts.
- **Integration Tests** (command = apply): Instructs Terraform to provision live temporary infrastructure, run tests, and automatically run a cleanup/destroy phase

`Terratest`: Best for complex integration testing and end-to-end multi-tier setups. It can hit actual endpoints, make HTTP requests, or run SSH scripts to prove live infrastructure functions as intended.
`Terragrunt`: A tool built on top of Terraform to enhance its capabilities. It adds an extra abstraction layer to simplify organizing and managing Terraform code, introducing concepts like modularity, inheritance, and reusability. This allows teams to share and reuse code across multiple Terraform projects, while also offering more robust configuration options and commands for deployment and state management.

## 6. Missing Backup Strategies
A state file is your single source of truth for your infrastructure. If this file is lost, corrupted, or overwritten without a backup, Terraform forgets what it has built. 

- **Remote Backends**: Store your Terrraform state file on cloud. With proper encryption and locking mechanism. 
- **Multiple Copies**: Even if your main storage is secure, make extra copies of your state file in a completely different place.

---
---

## State Commands

1. List resources: `terraform state list`
2. Show resource: `terraform state show google_compute_instance.web`
3. Move resource: `terraform state mv`
4. Remove from state: `terraform state rm`

---

***Interview Keywords:***
```text
Source of Truth
Resource Mapping
State File
Remote Backend
Infrastructure Tracking
Drift Detection
```

