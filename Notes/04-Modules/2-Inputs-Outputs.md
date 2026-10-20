# Module Inputs

Module Inputs are values passed from a parent module (usually the root module) into a child module.

1. **Parent Modules**
- Simply put, a parent module (also known as a *“calling module”* is a module that is calling other child modules in terraform.
- The parent module acts as a wrapper for the child modules, providing input variables and outputs that are used by the child modules to perform their tasks.

2. **Child Modules**
- A child module in terraform is a module that is called and used by another (parent) module. 
- Child modules encapsulate specific infrastructure components and allow for the reuse of terraform code, making it easier to manage and maintain complex infrastructure. 
- Child modules are defined and referenced within the parent module, with inputs and outputs being passed between the parent and child modules to configure and manage infrastructure components.

```text
Variables
     ↓
Module Inputs
     ↓
Child Module
```
They allow modules to be reusable and configurable.

A module receives input through variables

## Input Flow

```text
Root Module
      ↓
Pass Inputs
      ↓
Child Module
      ↓
Resources
```

![img](https://www.edrandall.uk/posts/tf-modules-vars/terraform-modules-2.png)

1. The parent (or calling) module is defined in the `main.tf` file.
2. The Child module contains references to this variable in its code: The variable is defined in `variables.tf` and in both 

---

## Input Types

Terraform supports all variable types.
1. String
2. Number
3. Boolean
4. List
5. Map
6. Object


Interview Keywords:
- Module Inputs
- Variables
- Parameterization
- Reusable Modules
- Validation
- Type Safety
- Sensitive Values

---

# Module Outputs

Module Outputs are values that a child module exposes to its parent module.

```text
Variables
      ↓
Module
      ↓
Resources
      ↓
Outputs
      ↓
Parent Module
```

**Inputs go into a module. Outputs come out of a module.**

### Why Do We Need Outputs?

Suppose a Network Module creates:
- VPC
- Subnet
- Firewall

Another module needs: VPC ID

Only through the Module Outputs that information can be accessed.

Outputs are the primary way modules communicate.

```text
Network Module
       ↓
Outputs VPC ID
       ↓
GKE Module Uses VPC ID
```

## Accessing Outputs

Parent module: `module.<module_name>.<output_name>`

```hcl
output "network_name" {
  value =
  google_compute_network.main.name
}

module.network.network_name
```

## Common Resource Attributes Exposed

1. ID
```hcl
output "network_id" {
  value = google_compute_network.main.id
}
```
2. Name

```hcl
output "network_name" {
  value = google_compute_network.main.name
}
```
3. Self Link: a `self_link` is a read-only attribute primarily used by the Google Cloud Platform (GCP) provider to return the official, fully-qualified URI (Uniform Resource Identifier) of a cloud resource

```hcl
output "network_link" {
  value = google_compute_network.main.self_link
}
```
4. Email: For IAM service accounts

```hcl
output "service_account_email" {
  value = google_service_account.app.email
}
```
4. IP Address

```hcl
output "public_ip" {
  value = google_compute_instance.web.network_interface[0].access_config[0].nat_ip
}
```
---

## Output Dependencies
Terraform automatically understands:

```text
VPC
 ↓
Output
```
No explicit dependency needed.

---

## Output Descriptions
Add documentation.

```hcl
output "network_id" {
  description = "ID of the VPC network"
  value = google_compute_network.main.id
}
```
---

# Sensitive Outputs

To hide the sensitive outputs from being printed to the state file or outputs. 

Used for:
- Passwords
- Tokens
- Secrets
- API Keys

```hcl
output "db_password" {
  value     = var.db_password
  sensitive = true
}
#### Output: (sensitive value)
```

---

Interview Keywords:
- Module Outputs
- Resource Sharing
- Module Communication
- Parent Module
- Child Module
- Sensitive Outputs
- Reusable Infrastructure
