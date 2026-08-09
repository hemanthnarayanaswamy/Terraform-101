# Introduction to Terraform 

`Infrastructure as Code (IaC)` is a DevOps practice where infrastructure—such as servers, networks, databases, and load balancers—is defined, provisioned, and managed using machine-readable configuration files instead of manual processes. 

Terraform, developed by HashiCorp, is an industry-standard Infrastructure as Code (IaC) tool used to build, modify, and manage infrastructure safely and efficiently.

- Automates infrastructure provisioning instead of manual console configuration.
- Enables version control, collaboration, and repeatable deployments.
- Reduces human errors while improving scalability and consistency.

![t2](https://spacelift.io/_next/image?url=https:%2F%2Fspaceliftio.wpcomstaging.com%2Fwp-content%2Fuploads%2F2023%2F03%2Fterraform-architecture-diagram.png&w=3840&q=75)

Terraform creates and manages resources on cloud platforms and other services through their application programming interfaces (APIs). Providers enable Terraform to work with virtually any platform or service with an accessible API.

## How Does Terraform Work ?

![t1](https://web-unified-docs-hashicorp.vercel.app/api/assets/terraform/latest/img/docs/intro-terraform-workflow.png)

The core Terraform workflow consists of three stages:

1. `Write`: You define resources, which may be across multiple cloud providers and services. For example, you might create a configuration to deploy an application on virtual machines in a Virtual Private Cloud (VPC) network with security groups and a load balancer.
2. `Plan`: Terraform creates an execution plan describing the infrastructure it will create, update, or destroy based on the existing infrastructure and your configuration.
3. `Apply`: On approval, **Terraform performs the proposed operations in the correct order**, respecting any resource dependencies. 
    * For example, if you update the properties of a VPC and change the number of virtual machines in that VPC, *Terraform will recreate the VPC before scaling the virtual machines.*

* Terraform offers **Idempotency**, with Terraform, running the same script multiple times will intelligently maintain the state and create only the required resources, preventing redundant costs.
* Terraform is **Declarative**, You do not write step-by-step instructions. You describe the final infrastructure you want, and Terraform figures out the actions.

Here is the Terraform Deep workflow for Production

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform destroy
```

## Terraform Architecture

##### 1. The Core (Engine)
This is the binary you run on your laptop. It reads your configuration files and compares them to the current state of your infrastructure to calculate what needs to be done.

##### 2. Providers 
Terraform doesn't know how to talk to AWS or Azure directly. It uses Providers plugins that *translate Terraform code into API calls* for specific platforms.
    - AWS Provider, Azure Provider, Kubernetes Provider.

##### 3. State File `terraform.tfstate`
This is the **brain** of Terraform. It maps your code to the real-world resources. 
* If you delete a resource from your code, Terraform looks at the state file to find the `ID` of the real resource and delete it from the cloud. 
* this file is stored remotely (e.g., in an AWS S3 bucket) so everyone works off the same map.

---

## Core Elements

#### 1. Terraform CLI
Terraform helps you automate the creation and management of infrastructure. To see a list of available commands in Terraform, you can run: `terraform --help`

This command will display all the available commands, with the most commonly used ones listed first. The primary Terraform commands include:
- **init**: Prepares your directory to run other Terraform commands.
- **validate**: Checks if the configuration is valid.
- **plan**: Shows what changes will be made to your infrastructure.
- **apply**: Executes the changes to create or modify your infrastructure.
- **destroy**: Deletes the infrastructure that was previously created.

#### 2. Terraform Language
Terraform uses HashiCorp Configuration Language (HCL) to define infrastructure. HCL is designed to be both easy to read by humans and understandable by machines.

Infrastructure elements managed by Terraform are called `resources`. 

These can include virtual machines, S3 buckets, VPCs, and databases. Each resource is defined in a block, like this example for creating an AWS VPC:
```bash
resource "aws_vpc" "default_vpc" {
    cidr_block = "172.31.0.0/16"
    tags = {
        Name = "example_vpc"
    }
}
```
#### 3. Terraform Provider
Terraform Provider defines the resource types and data sources Terraform can manage for that platform. Providers allow users to provision, configure, and manage cloud services, databases, networks, and more from a single workflow.

- Acts as a bridge between Terraform and infrastructure platforms.
- Defines the resources and data soruces available for management. 
- Supports cloud providers, data centers, network devices and databases. 
- Enables consistent provisioning across multiple environments. 

[List of all Terraform Providers](https://registry.terraform.io/browse/providers)

#### 4. [Terraform Modules](https://medium.com/@codebob75/terraform-modules-explained-with-code-example-f56b3f8baaa1)
A Terraform module is a container for a set of related resources that perform a specific task, enabling organized and reusable infrastructure code. A module in Terraform is a self-contained bundle of Terraform configurations that can be reused and shared.

If you know **OOPs**, then a module is just like an object, in Command Line they are akin to Functions. Basically, it’s a piece of reusable code, we just package terraform code into a bundle and then we just use it by passing different variables.

Use modules when managing a group of resources that are repeatedly deployed with similar configurations. Avoid using modules for single, standalone resources.

![t3](https://miro.medium.com/v2/resize:fit:640/format:webp/0*5oTPZpFIeP3aYcRK.png)

When a child module is called from a parent module, it executes in its own environment.

###### What is a Module made of ?
A Terraform module is a directory that contains Terraform configuration files (`.tf` files). By convention, it is often stored in a ‘modules’ folder for clarity

![t5](https://miro.medium.com/v2/resize:fit:456/format:webp/1*kWokq8YM46lcgAwp9Op_hA.png)

- `main.tf` Contains the core resource definitions, data sources, and other logic for the module.
- `variables.tf` Declares input variables for the module, allowing customization of the module’s behavior and configuration.
- `outputs.tf` Defines the outputs of the module, which are values that are returned to the calling module or root module for further use.

- *Module Block*: Defined using the `module` block in Terraform configuration, which includes the following arguments:-
- *source*: Specifies the location of the module, which can be a local path or a URL.
- *name*: Provides a name to reference the module within the configuration.
- *version*: Specifies a particular version of the module to use.
- *Resources and Variables*: Within a module block, users can define the resources that make up the module, along with input and output variables. Input variables allow values to be passed into the module when it is called, and output variables allow the module to return values to the calling configuration.
- *Nesting*: Modules can be nested, enabling the creation of complex infrastructure architectures using a hierarchical structure.

#### 5. Terraform Provisioners
*Terraform provisioners* are tools used to execute scripts or commands on local or remote machines during the creation or destruction of resources. They are typically employed for tasks like configuring servers, transferring files, or running custom scripts that cannot be achieved through native Terraform providers. However, HashiCorp recommends using provisioners sparingly, as they introduce complexity and potential state management issues.

1. **File Provisioner**: Used to copy files or directories from the local machine to a remote resource.
2. **Local-Exec Provisioner**: Executes commands on the machine running Terraform. It is useful for tasks like setting environment variables or invoking local scripts.
3. **Remote-Exec Provisioner**: Executes commands on the remote resource after it is created. It also requires a connection block for SSH or WinRM access.

- Run commands or scripts after resource provisioning.
- Commonly used for file transfers and software setup.
- Can increase complexity and require elevated permissions.
- Recommended only when native Terraform resources cannot achieve the task.

> They should be used rarely. In GCP, prefer `startup scripts`, `cloud-init`, images or native Terraform resources.

#### 6. [Terraform State](https://dev.to/pandey-raghvendra/terraform-state-explained-what-it-is-how-it-works-and-why-it-breaks-1omp)
Terraform state files allows Terraform to compare the current infrastructure with the desired state and apply only the necessary changes.

When you run `terraform apply`, Terraform:
1. Reads your `.tf` configuration files
2. Reads the current state file to understand what already exists
3. Calls the cloud provider APIs to get the current real-world state
4. Computes a diff between desired state (config) and actual state (provider)
5. Applies the changes and updates the state file
6. 
Without state, Terraform would have no way to know that the `aws_instance.web` in your config corresponds to `instance i-0abc123def456` in AWS. It would try to create a new one every time you run apply.

State is also how Terraform tracks metadata that isn't visible in the config — *resource IDs, ARNs, IP addresses* assigned by the cloud provider, dependency ordering, and provider version constraints.

###### Local State vs Remote State

By default, ***Terraform stores the state file locally*** on the machine where it is executed `local state(terraform.tfstate)`. This approach is simple and effective for individual use or small projects but can introduce risks in collaborative environments.

`Remote state` solves this. Remote state stores the Terraform state file in a shared backend such as AWS S3, Azure Storage, or Terraform Cloud. It is considered a best practice for production environments because it enhances security, collaboration, and reliability.

**Common Remote Backends:**
- AWS S3 (often paired with DynamoDB for state locking)
- Terraform Cloud
- Azure Blob Storage
- Google Cloud Storage

- `State locking` When Terraform starts an operation that modifies state (plan, apply, destroy), it acquires a lock on the state file. Any other Terraform operation that tries to acquire the same lock will wait or fail, depending on whether you pass `-lock-timeout`.
- `State Drift` Drift happens when the real-world state of a resource no longer matches what's in the Terraform state file. This is usually caused by manual changes — someone logs into the AWS console and modifies a security group rule, or uses the AWS CLI to change an instance type, or another tool (CloudFormation, a script, another Terraform root) touches the same resource.

#### 7. [Terraform Private Module Registry](https://spacelift.io/blog/terraform-private-registry#how-does-a-terraform-private-registry-work)

Private module Registry enables teams to manage, reuse, and distribute infrastructure code internally instead of relying on public registries. By configuring authentication, users can seamlessly reference these modules in their Terraform projects.

Private registries also provide:
* **Access control**: Only authorized users or teams can see or use the modules and providers.
* **Version management**: You can publish multiple versions and control which ones are approved for production.
* **Auditability**: You can track who published which version and when.
* **Consistency**: Everyone uses the same, vetted Terraform components, reducing drift and errors.

<table><thead><tr><th><p dir="ltr"><span>Feature</span></p></th><th><p dir="ltr"><span>Terraform</span></p></th><th><p dir="ltr"><span>Ansible</span></p></th></tr></thead><tbody><tr><th><p dir="ltr"><span>Primary Use</span></p></th><td><p dir="ltr"><span>Focuses on setting up and managing infrastructure.</span></p></td><td><p dir="ltr"><span>Primarily for configuring systems and deploying applications.</span></p></td></tr><tr><th><p dir="ltr"><span>Language</span></p></th><td><p dir="ltr"><span>Uses HCL for infrastructure definitions.</span></p></td><td><p dir="ltr"><span>Uses YAML for defining tasks.</span></p></td></tr><tr><th><p dir="ltr"><span>Stability</span></p></th><td><p dir="ltr"><span>Automatically ensures resources are created only if necessary.</span></p></td><td><p dir="ltr"><span>Requires careful task definition to avoid duplication.</span></p></td></tr><tr><th><p dir="ltr"><span>Execution</span></p></th><td><p dir="ltr"><span>Manages infrastructure changes using plans and state.</span></p></td><td><p dir="ltr"><span>Executes tasks immediately without state tracking.</span></p></td></tr><tr><th><p dir="ltr"><span>Cloud Support</span></p></th><td><p dir="ltr"><span>Excellent multi-cloud capabilities.</span></p></td><td><p dir="ltr"><span>Useful for multi-cloud configurations but limited to system-level tasks.</span></p></td></tr></tbody></table>

#### 8. Basic Terraform File Layout

* `main.tf`: resources
* `providers.tf`: provider setup
* `variables.tf`: input variable
* `outputs.tf`: values printed after apply
* `terraform.tfvars`: actual variable values
* `.terraform.lock.hcl`: provider version lock file

#### 9. GCP quick Basics

* GCP resources live inside a Project. 
* We need `project ID`, `region` and `zone`
* Many GCP services need APIs enabled first
* Terraform uses the `hashicorp/google` provider
* For Authentication, use `Service Account JSON keys`
* State may contain `IDs`, `IPs`, names & `Secrets`. Never casually commit `terraform.tfstate` to GitHub.

---

## Installation
Need to Install Terraform.
```bash
## Linux Installation
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

## MacOS
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

terraform version
terraform --help
```
* We need to [install](https://cloudwebschool.com/docs/gcp/fundamentals/installing-gcloud/) the Google Cloud SDK

```bash
# MacOS
# Install with Homebrew (recommended)
brew install --cask google-cloud-sdk

# After the install completes, open a new terminal window
# PATH changes do not apply to already-open terminals

# Verify the install
gcloud version

# Run the setup wizard
gcloud init
```
```bash
# Add the Google Cloud package signing key
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
  | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg

# Add the repository
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] \
  https://packages.cloud.google.com/apt cloud-sdk main" \
  | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list

# Install
sudo apt-get update
sudo apt-get install google-cloud-cli

# Verify
gcloud version

# Run setup
gcloud init
```
#### First Time Setup with `gcloud init`

1. `gcloud init` first opens a browser window so you can authenticate with your Google account. Once completed, `gcloud` stores a credentia token locally.
2. Sets a GCP Project as your default. Every gcloud comamnd without an explicit `--project` flag will target this project.
3. ***Set a default region and zone:*** Optional, but strongly recommended, Without these defaults, any command that needs a location will prompt you every time.

* Verify you Installation
```bash
# 1. Confirm gcloud is on your PATH and installed correctly
gcloud version

# 2. Confirm your sign-in worked and see which account is active
gcloud auth list

# 3. Confirm a default project is set
gcloud config get-value project

# 4. Confirm region and zone defaults are set
gcloud config get-value compute/region
gcloud config get-value compute/zone

# 5. Make a real API call to verify credentials and connectivity
gcloud compute regions list --limit=3

# If step fails, then its a authentication error
# rerun and sign-in again
gcloud auth login
```
#### Setup Application Default Credentials
In GCP, every identity is either a `user identity` (a human) or a `service account` (a workload or application). User identities sign in interactively with a password. Service accounts authenticate automatically using short-lived tokens. The practical rule is straightforward: humans use user identities, automated code uses service accounts.

There are two separate authentication commands, and they unlock two different things. Think of them as two different keys for two different locks.

- `gcloud auth login` gives you a key to run gcloud commands from the terminal. This is what `gcloud init` handles automatically.
- `gcloud auth application-default login` gives your code a key to call GCP APIs directly. This one is not run by `init` and must be set up separately.

**EXAMPLE:** *If you write code that calls GCP APIs (a Python script using the Cloud Storage client, a Node.js app using Firestore, a Go service querying BigQuery), you need Application Default Credentials (ADC) set up locally. Without it, your code will fail with authentication errors even if gcloud commands themselves work fine.*

```bash
# Set up ADC so local code can call GCP APIs as your user account
gcloud auth application-default login

# Confirm which identity ADC will use
gcloud auth application-default print-access-token

# For local testing that mirrors production: impersonate a service account
gcloud auth application-default login --impersonate-service-account=backend-api@my-project.iam.gserviceaccount.com
```
> Do not commit `service account` key files or `ADC` credential files to a code repository. Use `ADC` for **local development**. For code running on GCP infrastructure, attach a `service account` to the resource rather than embedding a key file.

The `GOOGLE_APPLICATION_CREDENTIALS` environment variable: if set, ADC uses the key file it points to

> For local development, developers also authenticate as their user identity through Application Default Credentials so that local code can call GCP APIs.
> In production, always prefer an attached service account over setting `GOOGLE_APPLICATION_CREDENTIALS` to a key file. 

#### How it works after installation

1. `gcloud` reads your local configuration (active project, region, zone) from a config file in your home directory.
2. It sings the request using your stored authentication credentials. 
3. It sends an HTTP request to the relevant GCP API, the same one the Cloud Console uses.
4. The API returns a result, which gcloud formats and prints to your terminal.

#### Keeping `gcloud` up-to-date

```bash
# Homebrew install: update with Homebrew
brew upgrade google-cloud-sdk

# apt install: update with apt
sudo apt-get upgrade google-cloud-cli

# Interactive installer or manual archive: update with gcloud
gcloud components update

# See what is installed and what has available updates
gcloud components list

# Install optional components as needed
gcloud components install kubectl       # Kubernetes CLI
gcloud components install bq
```

#### Using `gcloud` Command

```bash
gcloud [GROUP] [SUBGROUP] [COMMAND] [FLAGS]
```
1. **GROUP**: the GCP service or area: `compute`, `storage`, `iam`, `run`, `container`
2. **SUBGROUP**: the resource type within that service: `instances`, `buckets`, `service-accounts`, `clusters`
3. **COMMAND**: the action to perform: `create`, `list`, `describe`, `delete`, `update`
4. **FLAGS**: options that modify the command: `—zone=us-central1-a`, `—format=json`, `—quiet`

Refer to this Page for useful Commands [gcloud Commands](https://cloudwebschool.com/docs/gcp/fundamentals/gcloud-cli/)