# Terraform Coding Order

Refer to this link to get the actual syntax for the gcp resources [DOCUMENTATION](https://registry.terraform.io/providers/hashicorp/google/latest/docs)

1. versions.tf     → Terraform and provider requirements
2. providers.tf    → Provider configuration
3. variables.tf    → Input declarations
4. terraform.tfvars → Actual input values
5. main.tf         → Resources
6. outputs.tf      → Useful results
7. Run commands    → fmt, init, validate, plan, apply
8. Verify
9. Refactor        → locals, for_each, modules

## Step 1: Write `versions.tf`

This is always the first code recommended writing.
- What terraform versiond oes this project need ?
- What providers does this project use ? 
- Which provider versions are acceptable ?

```hcl
terraform {
  # Specifies the minimum required version of the Terraform CLI
  required_version = ">= 1.6.0, < 2.0.0"

  # Pin the required providers and their version constraints
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Allows >= 5.0 and < 6.0
    }
    random1 = {
      source  = "hashicorp/random1"
      version = ">= 3.5.0, < 4.0.0"
    }
    random2 = {
      source  = "hashicorp/random2"
      version = ">= 3.5.0, < 4.0.0"
    }
  }
}
```
After `terraform init`, Terraform will generate `.terraform.lock.hcl` ***Commit that lock file to git***

```hcl
terraform {
  required_version = ">= 1.5.0, < 2.0.0" 

  required_providers {
    google = {
      source  = "hashicorp/google" 
      version = "~> 6.0"           
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 6.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }
  }

  # -----------------------------------------------------------------------
  # 2. State Management (Remote Backend Configuration)
  # -----------------------------------------------------------------------
  # Configures where Terraform uploads and isolates your infrastructure state file

  backend "gcs" {
    bucket      = "my-gcp-terraform-state-prod-bucket" # GCS Bucket name (Must exist beforehand)
    prefix      = "terraform/state/infrastructure"     # File path grouping inside the bucket
    credentials = "/path/to/sa-key.json"               # OPTIONAL: Explicit SA path (ADC is preferred)
    
    # Advanced Optional Backend Tuning Fields:
    # impersonate_service_account = "tf-state-manager@://gserviceaccount.com"
    # kms_encryption_key         = "projects/my-project/locations/global/keyRings/my-ring/cryptoKeys/my-key"
  }

  # -----------------------------------------------------------------------
  # 3. Provider Metadata Declarations
  # -----------------------------------------------------------------------
  # Passes global configuration metadata down to specialized multi-tenant providers
  provider_meta "google" {
    module_name = "blueprints/terraform-google-network:v4.0.0"
  }

  # -----------------------------------------------------------------------
  # 4. Experimental Feature Flags
  # -----------------------------------------------------------------------
  # Opts into upcoming Terraform features before they are widely standard
  experiments = [
    # Example format (Note: Active features vary based on exact minor CLI releases)
    # module_variable_optional_attrs 
  ]
}
```

## Step 2: Write `providers.tf`
Now configure how Terraform connects to your existing GCP project.

```hcl
provider "google" {
  # Core Scope & Placement Fields
  # -----------------------------------------------------------------------
  project = "my-gcp-project-id" # The default project ID to manage resources in
  region  = "us-central1"       # Default region for regional resources
  zone    = "us-central1-a"     # Default zone for zonal resources

  # Authentication Fields
  # -----------------------------------------------------------------------
  # Path to or literal JSON contents of a Service Account key file
  credentials = file("/path/to/sa-key.json")

  # Service Account token exchange / impersonation configurations
  impersonate_service_account = "terraform-executor@://gserviceaccount.com"
  
  # Delegate accounts used during token generation/impersonation chains
  impersonate_service_account_delegates = [
    "intermediary-sa-1@://gserviceaccount.com"
  ]

  # Temporary raw OAuth 2.0 access token (alternative to credentials/ADC)
  access_token = "ya29.Gl..."

  # Custom OAuth 2.0 scopes requested when generating tokens
  scopes = [
    "https://www.googleapis.com/auth/cloud-platform",
    "https://googleapis.com"
  ]

  
  # Billing & Quota Settings
  # -----------------------------------------------------------------------
  # Forces APIs to check quota against a specific billing project rather than the resource's project
  user_project_override = true
  billing_project       = "my-billing-quota-project-id"


  # Performance, Engine & API Connection Settings
  # -----------------------------------------------------------------------
  # Global timeout configuration for single API HTTP requests
  request_timeout = "60s"

  # API request batching engine controls for highly parallel resources
  batching {
    enable_batching = true
    send_after      = "50ms"
  }

  # Maximum execution attempts for retrying transient API errors
  request_reason = "Provisioning Core Infrastructure via CI/CD"

  
  # Custom API Endpoint Overrides (For Private/Hybrid Clouds & VPC Service Controls)
  # -----------------------------------------------------------------------
  # Allows routing API calls to private endpoints or specific API gateways
  # Note: A snippet of common ones are shown; any valid GCP service endpoint can be added.
  custom_endpoints {
    compute           = "https://googleapis.com"
    container         = "https://googleapis.com"
    storage           = "https://googleapis.com"
    bigquery          = "https://googleapis.com"
    cloud_billing     = "https://googleapis.com"
    iam               = "https://googleapis.com"
    resourcemanager   = "https://googleapis.com"
    dns               = "https://googleapis.com"
    monitoring        = "https://googleapis.com"
    secret_manager    = "https://googleapis.com"
  }
}
```
```hcl
# GOOGLE BETA PROVIDER (Supports the exact same fields as above)
# =========================================================================
provider "google-beta" {
  project = "my-gcp-project-id"
  region  = "us-central1"
  zone    = "us-central1-a"
  
  # Example showing that google-beta can have its own endpoint or credentials setup
  user_project_override = false
}

# ALIASED PROVIDER CONFIGURATION (For multi-region/multi-project isolation)
# =========================================================================
provider "google" {
  alias   = "europe"
  project = "my-europe-project-id"
  region  = "europe-west1"
  zone    = "europe-west1-b"
}
```

Notice the reference to `var.` those variables do not exist yet, so declare them next. 

## Step 3: Write `variables.tf`
Declare only the information that the root module needs from you.

```hcl
# =========================================================================
# STANDARD STRING VARIABLE (The most basic implementation)
# =========================================================================
variable "gcp_project_id" {
  type        = string
  description = "The target Google Cloud Project ID where all infrastructure will be provisioned."
  default     = "my-production-project-123"
}

# =========================================================================
# SENSITIVE & COMPREHENSIVE COMPLEX VARIABLE
# Demonstrates validation rules, custom error messages, and safety controls.
# =========================================================================
variable "db_password" {
  type        = string
  description = "The master password for the Cloud SQL database instance."
  sensitive   = true # Hides the value from showing up in console output and UI logs.

  # Validation Rule 1: Minimum character length
  validation {
    condition     = length(var.db_password) >= 16
    error_message = "The db_password value must be at least 16 characters long."
  }

  # Validation Rule 2: Pattern matching via Regex (Must contain a special character)
  validation {
    condition     = can(regex("[!@#$%^&*(),.?\":{}|<>]", var.db_password))
    error_message = "The db_password value must contain at least one special character."
  }
}

# =========================================================================
# LIST VARIABLE (Ordered collection of elements of the same type)
# =========================================================================
variable "gcp_regions" {
  type        = list(string)
  description = "An ordered list of target regions to deploy secondary multi-region setups."
  default     = ["us-east1", "us-west1", "europe-west1"]
}

# =========================================================================
# SET VARIABLE (Unordered collection of unique values)
# =========================================================================
variable "authorized_networks" {
  type        = set(string)
  description = "A set of unique external CIDR blocks allowed to access the cluster endpoint."
  default     = ["192.168.1.0/24", "10.0.0.0/16"]
}

# =========================================================================
# MAP VARIABLE (Key-Value lookup tables)
# =========================================================================
variable "resource_labels" {
  type        = map(string)
  description = "A structural map of key-value pairs applied as metadata labels to resources."
  default = {
    environment = "production"
    managed_by  = "terraform"
    team        = "devops"
  }
}

# =========================================================================
# OBJECT VARIABLE WITH OPTIONAL ATTRIBUTES (Complex Data Structural Schema)
# Uses the `optional()` modifier to make specific fields nullable/defaultable.
# =========================================================================
variable "gke_cluster_config" {
  type = object({
    cluster_name = string
    node_count   = number
    machine_type = string
    
    # Optional field: If omitted by the caller, it defaults to null
    enable_autoscaling = optional(bool)
    
    # Optional field with an explicit default value if omitted by the caller
    disk_size_gb = optional(number, 100)
    
    # Nested Object structure
    network_config = object({
      vpc_name   = string
      subnet_name = string
    })
  })

  description = "The complete configuration schema matrix for provisioning GKE clusters."

  default = {
    cluster_name       = "prod-gke-core"
    node_count         = 3
    machine_type       = "e2-standard-4"
    enable_autoscaling = true
    disk_size_gb       = 200
    network_config = {
      vpc_name    = "prod-vpc"
      subnet_name = "gke-subnet"
    }
  }

  # Structural data validation (Ensuring node limits are maintained across environments)
  validation {
    condition     = var.gke_cluster_config.node_count >= 3 && var.gke_cluster_config.node_count <= 50
    error_message = "GKE node pool counts for production must scale strictly between 3 and 50 nodes."
  }
}

# =========================================================================
# TUPLE VARIABLE (Fixed-length sequence with unique types per position)
# =========================================================================
variable "network_routing_priority" {
  type        = tuple([string, number, bool])
  description = "A strict positional data configuration packet: [Route Name, Priority Metric, Is Active]."
  default     = ["default-internet-route", 1000, true]
}

# =========================================================================
# ANY TYPE VARIABLE (Bypasses structural checks — Use sparingly!)
# =========================================================================
variable "legacy_custom_metadata" {
  type        = any
  description = "Accepts any structural input form factor (strings, numbers, arrays, or deep nested maps)."
  default     = null
}
```
A value usually becomes a variable when:
- the user must supply it;
- it changes between projects or environments;
- it is reused in multiple places;
- it should not be hardcoded.

Do not turn every value into a variable. Start with only the values that genuinely need to change.

## Step 4: Write `terraform.tfvars`
Now provide the actual values for the variables.

The core difference between `variables.tf` and `terraform.tfvars` is **declaration vs. assignment.** Think of `variables.tf` as defining the blueprint or schema (what variables exist and what rules they must follow), while `terraform.tfvars` provides the actual data (the concrete values used for a specific deployment)

 **Feature**                       | `variables.tf` (The Blueprint)                                                  | `terraform.tfvars` (The Data) 💾**                                                                     
-----------------------------------|----------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------
 **Primary Purpose**               | Declares that a variable exists.                                                       | Assigns specific values to declared variables.                                                         
 **What it contains**              | Variable names, types, descriptions, validation rules, and optional fallback defaults. | Key-value pairs (variable_name = "value").                                                             
 **Can you define new variables?** | Yes, this is where they are created.                                                   | No, you can only give values to variables already declared.                                            
 **Source Control (Git)**          | Always commit to Git so others know what variables the code expects.                   | Usually ignore (.gitignore), especially if it contains environment-specific data or sensitive secrets. 
 **How it loads**                  | Automatically parsed as part of the Terraform configuration.                           | Automatically loaded by Terraform during plan or apply.    

Terraform automatically loads any file named `terraform.tfvars` or file ending with `*.auto.tfvars` when present in the root directory.

> If you are managing multiple stages (e.g., staging vs. production), you can name files like `prod.tfvars/dev.tfvars` and pass them explicitly using the command line flag: `terraform apply -var-file="production.tfvars"`

```hcl
# Standard String Assignment
gcp_project_id = "my-production-project-123"

# Sensitive String Assignment (Plain text here, but masked in execution plans)
db_password = "SuperSecurePassword!99#"

# List Assignment (Ordered collection of strings)
gcp_regions = [
  "us-central1",
  "us-east1",
  "europe-west1"
]

# Set Assignment (Unique collection of strings)
authorized_networks = [
  "192.168.1.0/24",
  "10.0.0.0/16"
]

# Map Assignment (Key-value metadata dictionary)
resource_labels = {
  environment = "production"
  managed_by  = "terraform"
  team        = "devops"
  cost_center = "cc-4091"
}

# Complex Object Assignment (Nested maps/primitives matching object schema)
gke_cluster_config = {
  cluster_name       = "prod-gke-core"
  node_count         = 5
  machine_type       = "e2-standard-8"
  enable_autoscaling = true
  disk_size_gb       = 250
  network_config = {
    vpc_name    = "prod-vpc"
    subnet_name = "gke-subnet"
  }
}

# Tuple Assignment (Strictly ordered positional data array)
network_routing_priority = [
  "default-internet-route", 
  1000, 
  true
]

# Any Type Assignment (Arbitrary structures or JSON payloads)
legacy_custom_metadata = {
  legacy_owner = "sysadmin-team"
  legacy_id    = 88492
  active       = false
}
```

## Step 5: Write `main.tf`
To write a successful `main.tf` for an entire infrastructure, you need a mental model that mimics how Google Cloud itself handles resources.

### The Mental Model: The Infrastructure Pyramid
Think of your infrastructure as a pyramid built from the ground up. You cannot build a higher layer without the layer beneath it existing first.

```ini
       ▲
      / \      4. APPLICATION LAYER (Compute Engines, GKE, Cloud SQL)
     /   \     3. SECURITY & IDENTITY LAYER (IAM Roles, Service Accounts, KMS Keys)
    /     \    2. FOUNDATION LAYER (VPC, Subnets, Firewalls, Cloud NAT)
   /_______\   1. INITIALIZATION LAYER (Project, APIs, Resource Management)
```
1. **Initialization** Enabling the APIs and setting up organizational boundaries.
2. **Foundation** Setting up your isolation boundaries 
3. **Security & Identity** Creating Service Accounts and granting them the Least Privilege via IAM and managing encryption keys.
4. **Application & Data** Deploying actual business value—GKE clusters, VMs, Cloud SQL instances, Cloud Storage buckets.

### Guide for `main.tf`

1. LOCAL VARIABLES BLOCK (Internal processing & code-deduplication)
```hcl
locals {
  name_prefix = "${var.environment}-${var.business_unit}"
  
  # Structural map merging standard and environment-specific labels
  common_labels = merge(var.resource_labels, {
    deployment_engine = "terraform"
    last_updated      = "2026-09-16"
  })
}

```

2. DATA SOURCES BLOCK (Fetching read-only metadata from GCP)
```hcl
# Fetches details about the active Google client configuration (like the active token)
data "google_client_config" "current" {}

# Fetches a list of available Compute zones in the target region dynamically
data "google_compute_zones" "available" {
  region = var.gcp_region
  status = "UP"
}
```

3. INITIALIZATION LAYER (Enabling Google APIs)
```hcl
resource "google_project_service" "enabled_apis" {
  for_each = toset([
    "://googleapis.com",
    "://googleapis.com",
    "://googleapis.com"
  ])
  
  project            = var.gcp_project_id
  service            = each.key
  disable_on_destroy = false
}
```
4. FOUNDATION LAYER (Networking Infrastructure)
```hcl
resource "google_compute_network" "vpc_network" {
  name                    = "${local.name_prefix}-vpc"
  auto_create_subnetworks = false
  project                 = var.gcp_project_id
  
  # Ensure APIs are fully enabled before trying to provision a network
  depends_on = [google_project_service.enabled_apis]
}

resource "google_compute_subnetwork" "private_subnet" {
  name                     = "${local.name_prefix}-private-subnet"
  ip_cidr_range            = "10.0.1.0/24"
  region                   = var.gcp_region
  network                  = google_compute_network.vpc_network.id
  private_ip_google_access = true # Crucial for apps to securely reach Google APIs
}
```

5. SECURITY & IDENTITY LAYER (Workload Service Accounts)
```hcl
resource "google_service_account" "app_sa" {
  account_id   = "${local.name_prefix}-app-sa"
  display_name = "Runtime Service Account for Core Applications"
  project      = var.gcp_project_id
}

resource "google_project_iam_member" "sa_storage_viewer" {
  project = var.gcp_project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.app_sa.email}"
}
```
6. APPLICATION LAYER (Compute / Virtual Machines)
```hcl
resource "google_compute_instance" "app_server" {
  name         = "${local.name_prefix}-server"
  machine_type = "e2-medium"
  # Pulls the first operational zone returned dynamically from our Data source block
  zone         = data.google_compute_zones.available.names[0] 

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 50
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.private_subnet.id
    # Omitting the 'access_config' block entirely keeps this instance off the public internet
  }

  service_account {
    email  = google_service_account.app_sa.email
    scopes = ["cloud-platform"]
  }

  labels = local.common_labels
}
```

7. MODULE BLOCK (Reusing packaged/remote open-source code setups)
```hcl
module "cloud_storage_buckets" {
  source  = "terraform-google-modules/cloud-storage/google"
  version = "~> 5.0"

  project_id = var.gcp_project_id
  names      = ["${local.name_prefix}-media-assets", "${local.name_prefix}-backups"]
  prefix     = "corp"
  location   = var.gcp_region
  
  # Enforces IAM permissions at the bucket level cleanly
  set_admin_roles = true
  admins          = ["serviceAccount:${google_service_account.app_sa.email}"]
}
```

## Step 6: Write `outputs.tf`
The `outputs.tf` file defines the return values of your Terraform configuration. Think of outputs like the return statement in a programming function.

They are used to print critical information (like IP addresses or DNS names) directly to your CLI terminal after an execution, or to pass data from a child module up to a root configuration.

```hcl
# STANDARD STRING OUTPUT (The most basic implementation)
output "vpc_network_id" {
  value       = google_compute_network.vpc_network.id
  description = "The fully qualified unique resource URI identifier for the provisioned VPC network."
}

# OUTPUT AS A LIST
output "instance_network_details" {
  value = [
    aws_instance.web.public_ip,
    aws_instance.web.private_ip
  ]
  description = "This is list of ipaddres of a instance"
}

# OUTPUT AS A MAP OR OBJECT
output "database_connection" {
  value = {
    endpoint = aws_db_instance.main.endpoint
    username = aws_db_instance.main.username
    port     = aws_db_instance.main.port
  }
}

# Extracting from Multiple Resources
output "all_public_ips" {
  value = aws_instance.web[*].public_ip
}

# SENSITIVE OUTPUT (Masks values from printing out to consoles/logs)
# =========================================================================
output "database_connection_string" {
  # Combines resource attributes into a single functional dynamic string expression
  value       = "mysql://${google_sql_database_instance.db.private_ip_address}:3306/production"
  description = "The internal connection endpoint URI string for backend applications."
  
  # Prevents this value from being dumped as plain text into CLI stdout or CI/CD logs.
  # Note: This will still be stored as plain text inside your remote state file (GCS).
  sensitive   = true 
}

# CONDITIONAL & OPTIONAL ARGS OUTPUT (Pre-condition Checks)
# =========================================================================
output "load_balancer_public_ip" {
  value       = google_compute_forwarding_rule.global_lb.ip_address
  description = "The public-facing Anycast IP routing global internet traffic to frontends."

  # Pre-conditions act as a guardrail. If this condition evaluates to false, 
  # Terraform completely halts execution and rolls back before rendering the output.
  precondition {
    condition     = can(regex("^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}$", google_compute_forwarding_rule.global_lb.ip_address))
    error_message = "The external API returned an invalid or unallocated load balancer IP format."
  }
}


# COMPLEX MATRIX OUTPUT (Iterating and filtering lists or resources)
# =========================================================================
output "subnet_cidr_mapping" {
  # Uses a 'for' loop to transform an object list into a clean, human-readable map array
  value = {
    for subnet in google_compute_subnetwork.private_subnets : subnet.name => subnet.ip_cidr_range
  }
  description = "A dynamically computed key-value map mapping subnet names directly to their assigned CIDR blocks."
}

# RESOURCE PASSTHROUGH OUTPUT (Exporting an entire object schema)
# =========================================================================
output "compute_instance_telemetry" {
  # Instead of exporting individual attributes like .id or .name, you can pass out 
  # the entire resource block object so upstream modules can access any nested attribute.
  value       = google_compute_instance.app_server
  description = "The entire structural configuration snapshot block of the deployed compute machine entity."
}


# DEPENDS_ON EXPLICIT OUTPUT (Rare use case - forcing sequencing control)
# =========================================================================
output "iam_policy_status" {
  value       = "IAM bindings securely attached."
  description = "An execution checkpoint flag tracking role assignment processing windows."

  # Forces Terraform to finish constructing the database and logging pipelines 
  # entirely before calculation evaluation loops parse this output value out.
  depends_on = [
    google_project_iam_member.sa_storage_viewer,
    google_logging_project_sink.audit_sink
  ]
}
```

## Step 7: Write `.gitignore`

```bash
.terraform/
*.tfstate
*.tfstate.*
crash.log
crash.*.log
*.tfplan
*.tfvars
*.tfvars.json
```

## Step 8: Run the complete Workflow

1. `gcloud auth application-default login`
2. `terraform fmt -recursive`
3. `terraform init`
4. `terraform validate`
5. `terraform plan -out=tfplan`
6. `terraform apply tfplan`