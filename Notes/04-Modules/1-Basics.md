# Modules Basics

A Terraform module is a collection of standard configuration files in a dedicated directory. Terraform modules encapsulate groups of resources dedicated to a single task, reducing the code you need to write for similar infrastructure components. 
`Module -> Reusable Terraform Code`

A module helps organize infrastructure into reusable building blocks.

A typical module can look like this:
```txt
├── main.tf
├── outputs.tf
├── README.md
└── variables.tf
```
Practically any Terraform configuration is already a module in itself. 

If you run Terraform in this directory, those configuration files would be considered a root module. It means that this configuration is the base of your operation, a core that you can expand further.

Very GCP common modules:
1. Network
2. GKE
3. IAM
4. Cloud SQL
5. Storage
6. Monitoring

### What is the difference between resources and modules in Terraform?

A resource in Terraform describes a piece of infrastructure that is going to be created (e.g., a VPC, a subnet, an EC2 instance, etc), whereas a module is a collection of resources that are used together to achieve a reusable use case.

## Real World Example

Suppose every environment `dev test prod` needs:
- VPC
- Subnet
- Firewall Rules

- ***Without modules***: we need to copy and paste the same code for those resource and modify according to the environment. 
- ***With modules***: we can create a Network Module and Reuse the same code.

Modules contain a collection of resources, for example when creating a SQL database you:
* Create the SQL server
* Create the SQL database
* Create the SQL endpoint
* Create the SQL privatelink

*Now if you do this once it’s fine, but what if you have multiple databases?*

Modules basically bundle those 4 resources into one, and you just have to pass different values for different environments.

---

# Module Types
There are primarily two types of modules depending on how they are written (`root` and `child` modules), and depending if they are published or not, we identify two different types as well (`local` and `published`).

![img1](https://miro.medium.com/0*PgKqKDKz8vQ5xhPs.png)

### 1. Root Module
The root module consists of all the resources defined in the `.tf` files in a Terraform configuration, meaning that all Terraform configurations have their own root module. 

Even if you are simply creating a `main.tf` that has just a locals block inside of it with a local variable, that is still considered a root module. 

Or simpy The Terraform configuration location where you run the terraform commands is called the `Root Module`

Even if you are simply creating a `main.tf `that has just a locals block inside of it with a local variable, that is still considered a root module. But keep in mind that every Terraform configuration can become a reusable module for other configurations. Every module can call other modules.

### 2. Child Module
A module called from another module. This is done by using a module block inside your Terraform configuration:

```text
# This is a child module.
modules/
└── network/

# Calling a module 
module "webservers" {
   source = "../webservers"
}
```
You can call the same module as many times as you want and configure it to your liking.

### 3. Local Module
A local module is a module that wasn’t published in any registry and when it is sourced, it is using the path to that particular module.

### 4. Published Module
A published module refers to a module that has been pushed to a Terraform Registry, or even simply on a VCS and has a tag associated with it. When a published module is sourced, the URL of that module is used either from the registry or from the VCS (version source control) itself.

```text
Root Module -> Network Module
Root Module -> GKE Module
Root Module -> Storage Module
```

## Basic Module Structure

```text
terraform/
├── main.tf
├── variables.tf
├── outputs.tf
│
└── modules/
    │
    └── network/
    |   ├── main.tf
    |   ├── variables.tf
    |   └── outputs.tf
    ├── gke/
    ├── sql/
    ├── storage/
    └── iam/
```
![img2](https://phoenixnap.com/kb/wp-content/uploads/2026/05/module-terraform-nested.jpg)

## When should you use Terraform modules?

The short answer to this question is ***always***.

The best way to think about writing Terraform code is to keep reusability in mind. HCL, being a declarative language, can be very wordy, so repeating the same configuration over and over again will be cumbersome. So usually, if you can, start by defining modules from the beginning and then try to use them as much as possible for maximum reusability. 

---
---

# How to use terraform Modules

## 1. Create the Module Block
To use a Terraform module, you have to first declare that you wish to use it in your current configuration. To do this, use the module block and provide the appropriate variable values:

Modules are called using:

```hcl
module "<NAME>" {

}

module "terraform_test_module" {
 source  = "spacelift.io/your-org/terraform-test-module/aws"
 version = "1.0.0"
 
 argument_1                     = var.test_1
 argument_2                     = var.test_2
 argument_3                     = var.test_3
}
```
#### `source` Argument
Terraform modules can be stored either locally or remotely. The source argument will change depending on their location.

Terraform modules can also be stored in so-called **registries**.  
  * Registries are places where you can find modules published by fellow Terraform users, or where you store the ones you have created — either privately, for your company/yourself, or publicly, for everyone to enjoy.

#### `version` Argument
Versioning enables you to control what module changes should be introduced into your infrastructure. It helps prevent damage to your infrastructure caused by unpredictable updates or faulty code. 

- `=` Only one version -- this specific version
- `!=` Other versions are fine, except this one here
- `> , >=, < , <` are used for comparisons. 
- `~>` This operator allows only the rightmost part of the version number to increment. `~> 2.6.0` - means you wish to use the newest patch version of the module `2.6.<something>`, but not the newer minor or major versions (2.7.0 or above).

#### Updating the Module Versions
After adding or changing a module source or version, initialize your working directory again with `terraform int` so Terraform can fetch the module code.

Terraform stores downloaded modules under a generated `.terraform/` directory in your working directory. ***Don’t commit this directory to version control.***

```bash
terraform int # will install any new modules you added since the last run.
terraform int -update # To update already installe dmodules and upgrade provider plugins within their allowed version constraints.
```

## 2. Passing Variables/Input to Modules

To pass input variables to a Terraform module, you must define the variables inside the child module first, and then assign values to those variables as arguments within the module block of the calling (parent) configuration.

> Think of a module like a function: the child module's variable block defines the function parameter, and the parent's module block passes the argument.

#### STEP 1: Define the variable in the child module.
Inside your child module directory (e.g., ./modules/aws_server), create a variables.tf file. Define the input variable that the module needs to accept.

```hcl
# ./modules/aws_server/variables.tf

variable "instance_type" {
  type        = string
  description = "The size of the EC2 instance"
  default     = "t3.micro" # Optional: provides a fallback value
}
```
#### STEP 2: Pass Values from the Parent Module.
In your root configuration (e.g., main.tf in your main directory), call the module using a module block. You pass values to the module by matching the exact names of the variables you defined in Step 1.

```hcl
# ./main.tf

module "web_server" {
  source = "./modules/aws_server"

  # Pass hardcoded values or references directly to the module variables
  instance_type = "t3.medium"
  environment   = "production"
}
```

#### Module Input Flow

```text
Variables
     ↓
Module
     ↓
Resources
```

## 3. Declare Module Outputs 
Sometimes you might need to use the values that are available in the already created resources. A Terraform module completely encapsulates those resources, and here’s how they can be accessed. 

* First, declare in your Terraform module that the selected value should be available as an output:

```hcl
output "network_id" {
  value = google_compute_network.main.id
  description = "A random string from an example resource on AWS."
}
```
* Then call this value like this: `module.<module_name>.<output>`
```hcl
resource "example_resource" "example" {
 [...]
 
 random_string = module.network.network_id
}
```

#### Module Output Flow

```text
Module Resources
         ↓
Outputs
         ↓
Root Module
```

---

### Common Module Sources

Terraform can load modules from:
1. Local Path: `source = "./modules/network"`
2. Git Repository `source = "git::https://github.com/company/network-module.git"`
3. Terraform Registry `source = "terraform-google-modules/network/google"`

---

### Module Benefits

1. Reusability
2. Consistency
3. Easier Maintenance
4. Simpler Code

### Common Mistakes

1. Hardcoding Values
2. No Outputs: without outputs other modules cannot use results
3. Large Monolithic Modules: prefer smaller focused modules