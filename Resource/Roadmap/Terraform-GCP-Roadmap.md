# Terraform Mastery Roadmap — GCP Edition (Zero → Interview-Ready)

> Companion to the AWS roadmap. Same block-by-block, project-driven, gate-before-you-advance structure — but rebuilt around **Google Cloud's genuinely different patterns**: the resource hierarchy, its IAM model, keyless auth, API-enablement ordering, and GCP's multi-piece load balancer. Assumes a heavy daily sprint, brand-new-to-Terraform start, targeting the HashiCorp Associate cert + senior/staff interview confidence.

**Same expectation-setting as AWS:** a sprint gets you to strong interview-ready intermediate/early-senior + cert pass. Staff-level *signal* comes from production reps afterward. Each block = concepts + hands-on + a "Prove It" gate. Don't advance until the gate passes.

---

## 0. Environment Setup (Day 0)

⬜ **Concepts:** what Terraform is (if new), the **`hashicorp/google`** vs **`google-beta`** providers, GCP's resource hierarchy (**Organization → Folders → Projects → Resources**), why *everything* lives inside a **Project**, and GCP auth options.

⬜ **GCP auth — learn the hierarchy of "good → best":**
- ❌ **Service account JSON key files** — the old way, a security liability (leakable long-lived credential). Avoid.
- ✅ **Application Default Credentials (ADC)** via `gcloud auth application-default login` — great for **local** development.
- ✅✅ **Service account impersonation** — you authenticate as yourself, then impersonate an SA with the exact permissions needed (no key files).
- ✅✅✅ **Workload Identity Federation (WIF)** — keyless auth for **CI/CD** (GitHub Actions → GCP with no stored secret). The modern best practice; know it cold for interviews.

⬜ **Tasks:**
1. Install Terraform 1.12+ (via `tfenv`/`mise`) and the `gcloud` CLI. Verify both.
2. Create a **GCP account + a dedicated sandbox project** (not a shared one). Link a billing account.
3. **Set a budget alert at $5–10** in Cloud Billing. GKE clusters, Cloud SQL, and forwarding rules cost real money — this is non-negotiable step one.
4. Run `gcloud auth application-default login` to set up ADC for local Terraform.
5. Install VS Code + HashiCorp Terraform extension; install `tflint`, `tfsec`/`trivy`, `terraform-docs`, `infracost`.
6. Note your **project ID** (globally unique, immutable) vs **project name** vs **project number** — you'll use the ID everywhere.

✅ **Prove It:** `terraform version`, `gcloud config list` shows your sandbox project, `gcloud auth application-default print-access-token` works, budget alert email arrived.

---

## 1. The Sprint Roadmap

### WEEK 1 — Foundations, Provider & Core Workflow

#### Block 1.1 — Provider config & the core loop ⬜
**Concepts:** the `google` provider block (`project`, `region`, `zone`), `required_providers` with `hashicorp/google`, the `init → plan → apply → destroy` loop, the lock file, state basics. **The API-enablement gotcha:** most GCP resources fail unless the relevant API is enabled first (`google_project_service`).

**Tasks:**
- Configure the provider with your project/region/zone.
- Enable an API declaratively: `google_project_service "compute"`.
- Create a single **Cloud Storage bucket** (`google_storage_bucket`). Run the full loop. Read every line of plan output.
- Deliberately create a Compute resource *without* enabling the API first and read the error — then fix it with `google_project_service` + an implicit dependency.

**Prove It:** Explain why `google_project_service` usually needs to exist before other resources, and how Terraform orders that.

#### Block 1.2 — Resources, data sources, the GCP hierarchy ⬜
**Concepts:** resource addressing, **data sources** (`google_project`, `google_compute_image`, `google_client_config`), implicit dependencies, the Organization → Folder → Project hierarchy, `google_project` / `google_folder` (org-level, may need elevated perms).

**Tasks:**
- Use `data "google_compute_image"` to fetch the latest Debian/Ubuntu image dynamically instead of hardcoding.
- Launch a `google_compute_instance` using that image data source in the default network.
- Use `data "google_project"` to read your current project number.

**Prove It:** Draw the implicit dependency graph (`terraform graph`) for your instance + its image + API enablement.

#### Block 1.3 — Variables, outputs, locals ⬜
**Concepts:** typed variables, `validation`, `sensitive`, variable precedence, `locals`, `outputs`. GCP naming rules (many resources: lowercase, hyphens, length limits — good `validation` practice).

**Tasks:**
- Parameterize project, region, zone, environment, machine type.
- Add a `validation` block enforcing GCP naming rules (lowercase + hyphens) on a resource name.
- Output the instance's internal + external IP and the bucket URL.

**Prove It:** Recite variable precedence. Explain variable vs local.

#### Block 1.4 — Expressions, functions, meta-arguments ⬜
**Concepts:** `for`/`for_each`/`count`, `dynamic` blocks, lifecycle meta-args, key functions. Reproduce the **`count` reindexing bug** and learn why `for_each` wins.

**Tasks:**
- Create N subnets with `for_each` over a map of region → CIDR.
- Use a `dynamic` block for firewall `allow` rules.
- Apply `prevent_destroy` to a "prod" bucket and try to destroy it.

**Prove It:** Explain the count reindexing problem and each lifecycle meta-arg with a GCP example.

> **🎯 Project 1 — "The Lone Resource":** Parameterized single Compute instance + GCS bucket with API enablement, data-source-driven image, variables/locals/outputs, validation, and labels. Commit it.

---

### WEEK 2 — State, IAM & Networking

#### Block 2.1 — State & the GCS backend ⬜
**Concepts:** what state is, **remote state via the `gcs` backend** (which has **native state locking built in** — no separate lock table needed, unlike the classic S3+DynamoDB setup you'll be asked to compare), state isolation, `terraform state` subcommands, the `import`/`moved`/`removed` blocks.

**Tasks:**
- Create a GCS bucket for state (with versioning on), migrate Project 1's local state to the `gcs` backend.
- `terraform state mv` to rename a resource with no recreate.
- Click-create a bucket in the console, then `import` it two ways (CLI + declarative `import {}`).
- Use a `removed` block to drop a resource from state without deleting it.

**Prove It:** Compare GCS-backend locking to the AWS S3+DynamoDB approach. Explain why state is sensitive and why it must lock.

#### Block 2.2 — GCP IAM (the biggest footgun) ⬜
**Concepts:** GCP's IAM model — **members** (`user:`, `serviceAccount:`, `group:`), **roles** (primitive/predefined/custom), and the **three resource flavors that behave very differently**:
- `google_project_iam_member` — **non-authoritative**, adds one binding (safe, additive).
- `google_project_iam_binding` — **authoritative for one role**, overwrites all members of that role.
- `google_project_iam_policy` — **authoritative for the whole project**, overwrites *everything* — **can lock you out**. Rarely used.

Plus custom service accounts (`google_service_account`) and impersonation.

**Tasks:**
- Create a service account, grant it a predefined role with `google_project_iam_member` (the safe one).
- Read the docs on `_policy` vs `_binding` vs `_member` and write a one-paragraph "when to use which."
- Set up SA impersonation in your provider config and re-run a plan as the impersonated SA.

**Prove It:** Explain, from memory, how `iam_member` / `iam_binding` / `iam_policy` differ and which one can lock you out of a project. **This is a top GCP interview question.**

#### Block 2.3 — VPC networking ⬜
**Concepts:** `google_compute_network` (with `auto_create_subnetworks = false` for a **custom-mode VPC** — the professional choice), `google_compute_subnetwork` (regional, with secondary ranges for GKE), `google_compute_firewall` (note: firewall rules are **network-level**, not instance-level like AWS security groups), `google_compute_router` + `google_compute_router_nat` for **Cloud NAT** (private instances → internet), private Google access.

**Tasks:**
- Build a custom-mode VPC with public + private subnets across regions.
- Add firewall rules (allow SSH from your IP, internal traffic, deny-by-default posture).
- Add a Cloud Router + Cloud NAT so private instances can reach the internet.
- Add secondary IP ranges on a subnet (prep for GKE).

**Prove It:** Explain how GCP firewall rules differ from AWS security groups (network-scoped, priority-based, tag/SA-targeted).

> **🎯 Project 2 — "The Network Foundation":** A reusable custom-mode **VPC module**: subnets with secondary ranges, firewall rules, Cloud Router + NAT, private Google access. Deploy via a dev/staging/prod directory layout with GCS remote state.

---

### WEEK 3 — Compute, Data, Serverless & Automation

#### Block 3.1 — Compute at scale (MIGs) ⬜
**Concepts:** `google_compute_instance_template`, **Managed Instance Groups** (`google_compute_instance_group_manager` / regional variant), `google_compute_autoscaler`, health checks, `metadata_startup_script` (the *right* way to bootstrap — avoid provisioners), instance templates + `create_before_destroy`.

**Tasks:**
- Build an instance template with a startup script (via `templatefile`).
- Create a regional MIG from it with an autoscaler (min/max instances, CPU target).
- Add a health check.
- Use `create_before_destroy` on the template so MIG updates don't cause downtime.

**Prove It:** Explain the template → MIG → autoscaler chain and why you version templates.

#### Block 3.2 — GKE, Cloud SQL, Cloud Run ⬜
**Concepts:**
- **GKE:** `google_container_cluster` with the standard pattern — `remove_default_node_pool = true` + separate `google_container_node_pool` resources (so you control node pools independently). Workload Identity, VPC-native (uses those secondary ranges).
- **Cloud SQL:** `google_sql_database_instance` (careful — has `deletion_protection` on by default; costs money), `google_sql_database`, `google_sql_user`, private IP via VPC peering.
- **Cloud Run:** `google_cloud_run_v2_service` — serverless containers, the fastest GCP thing to deploy.

**Tasks:**
- Deploy a GKE cluster with a custom node pool into Project 2's VPC (use the secondary ranges).
- Deploy a Cloud SQL Postgres instance with a private IP.
- Deploy a "hello world" container to Cloud Run and output its URL.

**Prove It:** Explain why you separate the GKE node pool from the cluster resource, and the `deletion_protection` gotcha on Cloud SQL.

#### Block 3.3 — Load balancing (GCP's multi-piece LB) ⬜
**Concepts:** GCP's global HTTP(S) LB is assembled from **many resources** (this trips everyone up): `google_compute_health_check` → `google_compute_backend_service` (or backend bucket) → `google_compute_url_map` → `google_compute_target_https_proxy` → `google_compute_global_forwarding_rule`, plus a managed SSL cert. Contrast with AWS's single ALB resource.

**Tasks:**
- Wire a global HTTPS load balancer in front of your MIG from 3.1: health check → backend service → URL map → target proxy → forwarding rule → managed cert.

**Prove It:** Draw the 5–6-resource LB chain from memory and explain what each piece does. **Classic GCP interview question.**

#### Block 3.4 — Secrets, security & CI/CD ⬜
**Concepts:** **Secret Manager** (`google_secret_manager_secret` + `_version`), pulling secrets via data source, ephemeral/write-only for passwords, `tfsec`/`checkov` scanning, **Workload Identity Federation** for keyless CI, policy-as-code (**Sentinel/OPA**, and GCP's **Organization Policy** constraints as a native guardrail layer).

**Tasks:**
- Store a DB password in Secret Manager; reference it (and discuss the ephemeral/write-only alternative so it stays out of state).
- Build a GitHub Actions pipeline authenticating to GCP via **WIF (no key file)**: run `fmt`/`validate`/`tflint`/`tfsec`, `plan` on PR, `apply` on merge with approval.
- Run `infracost` on a plan.

**Prove It:** Explain WIF end to end (why it's better than a JSON key) and diagram a safe team apply workflow.

> **🎯 Project 3 — "Three-Tier App on GCP":** Global HTTPS LB → regional MIG (web) → Cloud SQL (private IP), from your own modules, deployed through CI with WIF and remote state. Add Cloud Monitoring alert policies.

---

### WEEK 4 — Staff-Level Topics, Cert Cram & Capstone

#### Block 4.1 — Resource hierarchy, projects-as-code & org policy ⬜
**Concepts:** managing **projects, folders, and org policies as code**, the **Cloud Foundation Toolkit (CFT)** — Google's official `terraform-google-modules/*` registry modules (the GCP equivalent of `terraform-aws-modules`), the **project factory** pattern (spinning up standardized projects at scale), org policy constraints, VPC Service Controls (know it exists).

**Tasks:**
- Use the CFT **project-factory** module to create a standardized project (or read its source to understand the pattern).
- Read the CFT `network` and `kubernetes-engine` modules to see how Google structures production modules.

**Prove It:** Explain the project factory pattern and why large GCP orgs generate projects from a module.

#### Block 4.2 — State surgery, testing & governance ⬜
**Concepts:** splitting monolith state, cross-state data via `terraform_remote_state` or **outputs written to a GCS/Secret**, native `terraform test`, module-as-product versioning, drift detection (`plan -refresh-only`).

**Tasks:**
- Split Project 3 into network-state + app-state; wire them via remote state data source.
- Write a `*.tftest.hcl` test for your VPC module (assert subnet/range counts).
- Simulate drift in the console; reconcile with `-refresh-only`.

**Prove It:** Walk through migrating a large monolith state to component states with zero downtime.

#### Block 4.3 — Cert cram ⬜
Two tracks apply to you:
- **HashiCorp Terraform Associate (004)** — **cloud-agnostic**, so all your Terraform knowledge counts regardless of GCP. Same 8 domains and 004 deltas as the AWS roadmap (ephemeral/write-only, `check`/`precondition`/`postcondition`, `moved`/`removed`/`import`, HCP Terraform). This is your primary Terraform cert.
- **Google Cloud certs** (where Terraform is increasingly expected): **Associate Cloud Engineer** (foundational), **Professional Cloud DevOps Engineer**, and **Professional Cloud Architect**. These test GCP knowledge broadly; your Terraform work here directly supports the IaC portions. Verify current exam details on Google's site since Google refreshes them periodically.

**Tasks:**
- Take 2–3 timed HashiCorp Associate practice exams; write *why* each wrong answer is wrong.
- Drill the 004 command-behavior trivia.

**Prove It:** 85%+ on two consecutive practice exams.

> **🎯 Project 4 (CAPSTONE) — "GCP Platform in a Box":** A versioned, tested module library (VPC + GKE + Cloud SQL + IAM/service accounts + Secret Manager + monitoring), consumed by `environments/{dev,staging,prod}`, deployed via CI with **WIF**, guarded by tfsec + an org-policy/OPA rule, costed with infracost, with split state. Build, explain, destroy, recreate cleanly.

---

## 2. Project Ladder (Summary)

| # | Project | Teaches |
|---|---|---|
| 1 | The Lone Resource | HCL, provider, API enablement, data sources |
| 2 | The Network Foundation (custom VPC) | Modules, GCP networking, Cloud NAT, remote state |
| 3 | Three-Tier App on GCP | MIG + Cloud SQL + the multi-piece HTTPS LB, CI, WIF |
| 4 | GCP Platform in a Box (Capstone) | GKE, project/org patterns, governance, state at scale |
| 5 *(stretch)* | Multi-project + Shared VPC + folders | Resource hierarchy, cross-project networking |
| 6 *(stretch)* | Import a clicked-together project into TF | Brownfield adoption |

---

## 3. GCP-Specific Real-World Topics Interviewers Probe

Build a 2–3 sentence story for each — these are the GCP deltas beyond generic Terraform:

- **IAM authoritative vs non-authoritative:** the `iam_member`/`iam_binding`/`iam_policy` distinction and how `_policy`/`_binding` can wipe out access or lock you out.
- **API enablement ordering:** why `google_project_service` must precede resources and how you sequence it.
- **Keyless auth:** Workload Identity Federation vs service account JSON keys — why keys are a liability.
- **Service account impersonation** for least-privilege local runs.
- **The multi-resource HTTPS LB:** assembling health check → backend → URL map → proxy → forwarding rule.
- **Custom-mode vs auto-mode VPC** and why auto-mode is discouraged in production.
- **Shared VPC** (host project / service projects) for centralized networking across many projects.
- **Project factory / projects-as-code** for standardized project provisioning at scale.
- **GCS backend native locking** vs AWS S3+DynamoDB.
- **Cloud SQL `deletion_protection`** and other "costs-money / hard-to-delete" footguns.
- **Org Policy constraints** as a native guardrail complementing Sentinel/OPA.
- **google vs google-beta** provider and when you need beta.

---

## 4. GCP-Flavored Interview Questions

Practice out loud. (For the generic Terraform-language and staff questions, use the AWS roadmap's bank — those are cloud-agnostic.)

**Fundamentals**
1. How do you authenticate Terraform to GCP, from worst to best option?
2. Why must you often enable an API before creating a resource, and how does Terraform handle that ordering?
3. What's the GCP resource hierarchy, and where does everything live?
4. What's the difference between project ID, name, and number?
5. How is a GCP firewall rule different from an AWS security group?

**Mid-level**
6. Explain `google_project_iam_member` vs `iam_binding` vs `iam_policy`. Which is dangerous and why?
7. Why use a custom-mode VPC over auto-mode in production?
8. How do private instances reach the internet in GCP? (Cloud NAT/Router.)
9. Walk through assembling a global HTTPS load balancer in Terraform.
10. How does the GCS backend handle state locking compared to AWS?

**Senior**
11. Why is the GKE node pool usually a separate resource from the cluster? What breaks if it isn't?
12. Explain Workload Identity Federation and why it beats service account keys for CI/CD.
13. What is Shared VPC and when would you use it?
14. How do you provision many standardized projects at scale? (Project factory.)
15. How do you handle secrets so they never land in state on GCP?

**Staff / Architect**
16. Design a multi-project GCP org structure as code (folders, shared VPC, org policies). How do you balance central control vs team autonomy?
17. How do you enforce guardrails org-wide (allowed regions, required labels, no external IPs)? (Org Policy + Sentinel/OPA.)
18. A teammate applied a `google_project_iam_policy` and removed everyone's access. Walk through prevention and recovery.
19. How would you migrate a large clicked-together GCP org into Terraform incrementally?
20. Compare running this on HCP Terraform vs self-hosted CI with WIF.

**Scenario deep-dives**
- **S1 — The Lockout:** Someone used `iam_policy` authoritatively and dropped the Terraform SA's role. Diagnose and recover.
- **S2 — The LB That Won't Serve:** The HTTPS LB returns 502s. Walk the health-check → backend → MIG chain to find the break.
- **S3 — Shared VPC Rollout:** Centralize networking across 15 team projects using Shared VPC without downtime.
- **S4 — API Ordering Hell:** A fresh project apply fails on half the resources due to disabled APIs. Fix the ordering properly.
- **S5 — Keyless Migration:** Replace all service-account JSON keys in CI with Workload Identity Federation.

---

## 5. Resource Guide (GCP-Specific)

**Official:**
- HashiCorp Developer — "Get Started: Google Cloud" track.
- Terraform Google provider docs (`registry.terraform.io/providers/hashicorp/google`) — your daily reference; every resource + example.
- **Cloud Foundation Toolkit / `terraform-google-modules`** on the registry and GitHub — Google's production-grade modules (VPC, GKE, project-factory, IAM). Read their source to learn pro GCP module design.
- Google Cloud docs on Workload Identity Federation, Org Policy, Shared VPC, resource hierarchy.

**Hands-on:** your GCP sandbox project (with the budget alert set), Google Cloud free tier / free trial credits.

**Cert:** HashiCorp Terraform Associate (004) study guide + practice exams (cloud-agnostic); Google Cloud certification pages for ACE / Professional Cloud DevOps Engineer / Professional Cloud Architect (verify current details on Google's site).

**Tooling:** `gcloud`, `tflint`, `tfsec`/`trivy`/`checkov`, `terraform-docs`, `infracost`, GitHub Actions with WIF, HCP Terraform free tier.

---

## 6. AWS ↔ GCP Quick Mental Map

| Concept | AWS | GCP |
|---|---|---|
| Provider | `hashicorp/aws` | `hashicorp/google` (+ `google-beta`) |
| Account boundary | Account | **Project** (inside Org/Folders) |
| State backend | S3 + DynamoDB lock | **GCS** (native locking) |
| Keyless CI auth | OIDC + IAM role | **Workload Identity Federation** |
| Network | VPC + Security Groups | VPC + **network-level firewall rules** |
| Private egress | NAT Gateway | **Cloud Router + Cloud NAT** |
| Autoscaling group | ASG + Launch Template | **MIG + Instance Template + Autoscaler** |
| Managed K8s | EKS | **GKE** (`remove_default_node_pool` pattern) |
| Managed SQL | RDS | **Cloud SQL** (`deletion_protection` default) |
| Serverless container | Fargate/App Runner | **Cloud Run** |
| Load balancer | single ALB resource | **multi-resource** HTTPS LB chain |
| Secrets | Secrets Manager | **Secret Manager** |
| Official module lib | `terraform-aws-modules` | **Cloud Foundation Toolkit** (`terraform-google-modules`) |
| Org guardrails | SCPs + Sentinel/OPA | **Org Policy** + Sentinel/OPA |

---

### Final note
The Terraform *language* is identical across clouds — so your language workbook applies unchanged. What separates a GCP Terraform engineer is fluency in the GCP-specific traps: IAM authoritativeness, API ordering, keyless auth, the resource hierarchy, and the multi-piece LB. For every one of those, be ready to explain not just "how" but "why this and what breaks if you get it wrong" — that's the senior/staff signal.
