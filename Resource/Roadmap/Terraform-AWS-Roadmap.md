# Terraform Mastery Roadmap — Zero → Interview-Ready (AWS)

> **Your profile:** Brand new to Terraform · AWS-focused · 2–4 week heavy daily sprint · Goal = HashiCorp Associate cert + senior/staff interview confidence.

---

## 0. Read This First (Expectation-Setting)

A 2–4 week sprint from zero gets you to a **strong, interview-ready intermediate / early-senior level** and is more than enough to pass the **HashiCorp Terraform Associate (004)** cert. The 004 exam is multiple-choice/true-false (no hands-on labs), ~57–60 questions, ~70% to pass, valid 2 years, and aligns to **Terraform 1.12**.

What a sprint *cannot* fully manufacture is **staff-level signal**, which in interviews comes from production scars — "I once corrupted shared state and here's how I recovered," "here's how we governed 40 teams' modules." This roadmap *teaches* those concepts and *gives you the language to discuss them* (see the scenario bank), but plan to keep reinforcing with real work afterward. The fastest credibility boost post-sprint: get one non-trivial system into Terraform at work or in a personal AWS account and run it for real.

### How to use this document
- Each **Block** = concepts + hands-on tasks + a "Prove It" gate. **Do not advance until you pass the gate** (explain the concept out loud + the lab works).
- The **6 escalating projects** are the spine. Concepts exist to serve the projects.
- The **interview/scenario bank** is your daily warm-down: read 3–5 Q&As per day so the vocabulary becomes automatic.
- Mark each block: ⬜ not started · 🟡 in progress · ✅ gate passed.

### Daily cadence template (≈4–6 hrs)
| Time | Activity |
|---|---|
| 30 min | Review yesterday's notes + flashcards |
| 90 min | New concept block (read/watch + take notes in your own words) |
| 120 min | Hands-on lab / project work — **type everything, never copy-paste blind** |
| 45 min | Break stuff on purpose, read the error, fix it |
| 30 min | Interview-question warm-down (answer 3–5 out loud) |

---

## 1. Environment Setup (Day 0 — do before Week 1)

⬜ **Concepts:** what Terraform is (declarative IaC, provider plugins, state, the core workflow), Terraform vs CloudFormation/Pulumi/Ansible, OpenTofu (the open-source fork after the BSL license change) and why it exists.

⬜ **Tasks:**
1. Install Terraform 1.12+ (`tfenv` or `mise` so you can switch versions later). Verify `terraform version`.
2. Install the AWS CLI; create a **dedicated sandbox AWS account** (not your main one).
3. Create an IAM user/role for Terraform with least-privilege-ish admin in sandbox; configure `aws configure` with a **named profile** (never hard-code keys in `.tf`).
4. **Set an AWS budget alert at $5–10** so a forgotten `nat_gateway` or RDS instance doesn't cost you $200. This is the single most important setup step.
5. Install VS Code + the HashiCorp Terraform extension (syntax, fmt, validate, autocomplete).
6. Install `git`; create a private repo for all sprint work.
7. Install helpers: `tflint`, `tfsec` (or `trivy`), `terraform-docs`, `infracost`.

✅ **Prove It:** `terraform -help` runs, `aws sts get-caller-identity` returns your sandbox account, your budget alert email arrived, repo is initialized.

---

## 2. The Sprint Roadmap

### WEEK 1 — Foundations & Core Workflow

#### Block 1.1 — HCL syntax & the core loop ⬜
**Concepts:** HCL blocks/arguments/expressions, `terraform {}` settings, `required_providers`, `required_version`, the provider block, resources, the `init → plan → apply → destroy` loop, what `.terraform/`, `.terraform.lock.hcl`, and `terraform.tfstate` are.

**Tasks:**
- Write a config that creates a single S3 bucket. Run the full loop. Read every line of `plan` output.
- Inspect the state file (`terraform show`, `terraform state list`). Open the raw JSON once to demystify it — then never edit it by hand.
- Add a tag, re-plan, observe the diff. Change the bucket name, observe **replace** (destroy/create) vs **update in place**.

**Prove It:** Explain the difference between `+`, `~`, `-`, and `-/+` in plan output. Explain what the lock file pins and why you commit it.

#### Block 1.2 — Providers, resources, data sources ⬜
**Concepts:** provider configuration & aliases, multiple regions, resource arguments vs attributes, **data sources** (read existing infra), resource addressing (`aws_instance.web[0]`), implicit vs explicit dependencies, `depends_on`.

**Tasks:**
- Use a `data "aws_ami"` filter to dynamically fetch the latest Amazon Linux AMI instead of hard-coding an ID.
- Launch an EC2 instance into the default VPC using that data source.
- Add a second provider alias for a different region; create an S3 bucket in each.

**Prove It:** Draw the implicit dependency graph for your config (`terraform graph`). Explain why you rarely need `depends_on`.

#### Block 1.3 — Variables, outputs, locals ⬜
**Concepts:** input variables (types, defaults, `description`, `sensitive`, **validation** blocks), variable precedence (CLI `-var` > `*.auto.tfvars` > `terraform.tfvars` > env `TF_VAR_` > default), `locals`, `outputs`, the difference between a variable and a local.

**Tasks:**
- Refactor Block 1.2 to parameterize region, instance type, environment name.
- Add a `validation` block (e.g., instance type must be in an allowed list).
- Mark a variable `sensitive` and observe how it's hidden in plan output.
- Output the instance public IP and the bucket ARN.

**Prove It:** Recite the variable precedence order top to bottom. Explain when you'd use a `local` vs a `variable`.

#### Block 1.4 — Expressions, functions, meta-arguments ⬜
**Concepts:** built-in functions (`for`, `lookup`, `merge`, `coalesce`, `templatefile`, `cidrsubnet`, `try`, `flatten`), conditionals, `count` vs `for_each` (and **why `for_each` is usually safer**), `dynamic` blocks, the four lifecycle meta-args (`create_before_destroy`, `prevent_destroy`, `ignore_changes`, `replace_triggered_by`).

**Tasks:**
- Create N subnets with `for_each` over a map of AZ → CIDR (not `count`).
- Then deliberately reproduce the **`count` reindexing bug**: build 3 things with `count`, remove the middle one, watch Terraform try to destroy/recreate everything after it. This pain teaches the `for_each` lesson permanently.
- Use a `dynamic` block to generate security group rules from a variable.
- Apply `prevent_destroy` to a "prod" bucket and try to destroy it.

**Prove It:** Explain the `count` reindexing problem and when `for_each` fixes it. Explain each lifecycle meta-argument with a real use case.

> **🎯 Project 1 — "The Lone Resource":** A fully parameterized single-EC2-+-S3 module-less config with variables, locals, outputs, data sources, validation, and tags. Commit it. This is your HCL muscle-memory baseline.

---

### WEEK 2 — State, Modules & Real Structure

#### Block 2.1 — State deep dive ⬜
**Concepts:** what state is and why it exists, desired vs actual, `terraform refresh` behavior, **remote state** (S3 backend + native S3 state locking — DynamoDB locking is the legacy approach you'll still see in interviews), state isolation strategies, sensitive data in state (it's plaintext!), `terraform state` subcommands (`list`, `show`, `mv`, `rm`, `pull`, `push`), `import`, the modern **`import` block** (declarative import) and **`removed` block** (remove from state without destroying).

**Tasks:**
- Migrate Project 1's local state to a remote **S3 backend** with locking.
- `terraform state mv` to rename a resource without destroying it.
- Manually click-create an S3 bucket in the console, then **`import`** it into Terraform two ways: the CLI command and the declarative `import {}` block.
- Use a `removed` block to drop a resource from state while keeping the real infra.
- `terraform state rm` and re-import to feel the difference.

**Prove It:** Explain why state can't be edited by hand, why it must be locked, why it's sensitive, and the recovery steps if two engineers apply simultaneously.

#### Block 2.2 — Modules ⬜
**Concepts:** root vs child modules, module inputs/outputs, calling local modules, the **public Terraform Registry**, module versioning & pinning, module composition (modules calling modules), when NOT to make a module (premature abstraction), module design principles (small, single-purpose, sane defaults, documented).

**Tasks:**
- Extract Project 1 into a reusable local `module "web_server"`.
- Call it twice (dev + staging) with different inputs from one root config.
- Pull a real registry module (e.g., `terraform-aws-modules/vpc/aws`), pin its version, read its source to see how pros structure modules.
- Generate docs with `terraform-docs`.

**Prove It:** Explain semantic versioning constraints (`~>`, `>=`, `=`) and why pinning matters. Critique a module: is it too big? too rigid?

#### Block 2.3 — Multi-environment patterns ⬜
**Concepts:** **workspaces vs directory-per-environment** (and why most teams prefer directories/separate state for prod isolation), `*.tfvars` per env, backend config per env (`-backend-config`), DRY strategies, the role of tools like Terragrunt (know what problem it solves even if you don't adopt it).

**Tasks:**
- Restructure your repo into `environments/{dev,staging,prod}` each with its own backend state, sharing the same modules.
- Demonstrate the same module deployed to two envs with different sizing.
- Try CLI workspaces on a throwaway config, then articulate why you'd avoid them for prod.

**Prove It:** Argue both sides: "workspaces vs separate directories for environment isolation." Pick a side and defend it.

> **🎯 Project 2 — "The Network Foundation":** Build a production-shaped **VPC module** from scratch: public/private subnets across AZs, IGW, NAT gateway, route tables, NACLs vs security groups. Deploy it via the dev/staging/prod directory structure with remote state. This is the single most reused pattern in AWS interviews.

---

### WEEK 3 — Advanced Features, Security & Automation

#### Block 3.1 — Provisioners, lifecycle edge cases, dependencies ⬜
**Concepts:** why provisioners are a **last resort** (`local-exec`, `remote-exec`), `null_resource` / the modern `terraform_data`, `user_data` & `cloud-init` instead of provisioners, the dependency graph, `terraform graph`, targeting (`-target`) and why it's an emergency tool not a workflow.

**Tasks:**
- Bootstrap an EC2 web server via `user_data`/`templatefile` (the *right* way), then once via `remote-exec` (the *wrong* way) to feel the difference.
- Use `replace_triggered_by` to force instance replacement when a config hash changes.

**Prove It:** Explain why provisioners aren't tracked in state and the failure modes that creates.

#### Block 3.2 — Custom conditions, checks & sensitive data (004-heavy) ⬜
**Concepts:** **`precondition`/`postcondition`** blocks, standalone **`check {}`** blocks with assertions, **`moved`** blocks for safe refactors, **ephemeral values** and **write-only attributes** (handling secrets so they never land in state) — these are emphasized on the 004 exam.

**Tasks:**
- Add a `postcondition` asserting an AMI is x86_64.
- Add a `check` block that verifies an endpoint is reachable after apply.
- Refactor a resource's name using a `moved` block (no destroy).
- Use an ephemeral/write-only pattern for a DB password so it's absent from state.

**Prove It:** Explain how ephemeral values differ from `sensitive`, and where each shows up (or doesn't) in state and plan output.

#### Block 3.3 — Secrets, security & policy ⬜
**Concepts:** never commit secrets, integration with AWS Secrets Manager / SSM Parameter Store, `tfsec`/`trivy`/`checkov` static scanning, **Sentinel** vs **OPA** policy-as-code (governance/guardrails — staff-level vocabulary), least-privilege IAM for the Terraform principal, state encryption at rest.

**Tasks:**
- Pull a DB password from Secrets Manager via data source instead of a variable.
- Run `tfsec` on Project 2; fix three findings.
- Write one simple OPA/Sentinel-style rule in pseudocode: "deny any S3 bucket without encryption."
- Run `infracost` to see the dollar cost of a plan.

**Prove It:** Explain three distinct ways secrets leak in Terraform and how to prevent each.

#### Block 3.4 — CI/CD & collaboration ⬜
**Concepts:** the team workflow (PR → `plan` in CI → review → `apply` on merge), remote state locking in team context, `fmt`/`validate`/`tflint` as CI gates, **HCP Terraform** (formerly Terraform Cloud) — remote runs, VCS-driven workflows, projects, private module registry, drift detection — and where Atlantis fits.

**Tasks:**
- Build a GitHub Actions pipeline: on PR run `fmt -check`, `validate`, `tflint`, `tfsec`, and post a `plan`; on merge to main run `apply` (manual approval gate).
- Connect one config to HCP Terraform free tier and trigger a VCS-driven run.

**Prove It:** Diagram a safe team apply workflow and explain how it prevents the "two engineers, one state" disaster.

> **🎯 Project 3 — "Three-Tier App":** ALB → Auto Scaling Group (web) → RDS (private subnets), all from your own composed modules, deployed through CI with remote state and a `plan`-on-PR gate. Add CloudWatch alarms. This is the canonical interview build.

---

### WEEK 4 — Staff-Level Topics, Cert Cram & Capstone

#### Block 4.1 — Refactoring & state surgery at scale ⬜
**Concepts:** large-scale `moved`/`import` blocks, splitting a monolith state into multiple states, `terraform state mv` across configs, dealing with provider upgrades and breaking changes, `terraform plan -refresh-only` for drift, blast-radius thinking.

**Tasks:**
- Split Project 3's single state into network-state + app-state and wire them together with **remote state data sources** (`terraform_remote_state`) or, better, SSM parameter outputs.
- Simulate drift: change something in the console, run `-refresh-only`, reconcile.

**Prove It:** Walk through migrating a 500-resource monolith to multiple states with zero downtime — out loud, as if to an interviewer.

#### Block 4.2 — Testing, modules-as-products, governance ⬜
**Concepts:** native **`terraform test`** (HCL test files), `terraform validate`, contract testing for modules, semantic-versioned internal module registry, golden modules, platform-engineering mindset (self-service modules for app teams), drift detection at scale, cost governance.

**Tasks:**
- Write a `*.tftest.hcl` test for your VPC module asserting subnet counts and CIDRs.
- Document the module as a "product" with README, examples, inputs/outputs, versioning policy.

**Prove It:** Explain how you'd run a private module registry for 30 teams and prevent breaking-change chaos.

#### Block 4.3 — Cert cram (004) ⬜
Map your knowledge to the **eight 004 domains**:
1. IaC concepts & benefits
2. Terraform's purpose / multi-cloud / ecosystem
3. Core workflow & CLI basics (init/plan/apply/destroy, providers, resources)
4. Advanced CLI (workspaces, state commands, debugging, `TF_LOG`)
5. Modules (creation, inputs/outputs, registry, best practices)
6. Core workflow details (dependencies, lifecycle meta-args, targeting)
7. State management (remote state, locking, sensitive data)
8. HCP Terraform (remote runs, projects, private registry, Sentinel)

**Tasks:**
- Take 2–3 full timed practice exams; for every wrong answer, write *why* the right answer is right.
- Drill the 004 specifics: ephemeral/write-only, `check`/`precondition`/`postcondition`, `moved`/`removed`/`import` blocks, HCP projects.
- Memorize exact CLI command behaviors (the exam loves "what does `terraform state mv` do" trivia).

**Prove It:** Score 85%+ on two consecutive practice exams.

> **🎯 Project 4 (CAPSTONE) — "Platform in a Box":** A reusable, versioned, tested module library (VPC + EKS or ECS + RDS + IAM + observability), consumed by `environments/{dev,staging,prod}`, deployed via CI/HCP Terraform, secured with tfsec + a policy rule, costed with infracost, documented as products, with split state and remote-state wiring. **If you can build, explain, and destroy/recreate this cleanly, you interview well.**

---

## 3. Project Ladder (Summary)

| # | Project | Teaches |
|---|---|---|
| 1 | The Lone Resource | HCL, variables, data sources, lifecycle |
| 2 | The Network Foundation (VPC module) | Modules, multi-env, remote state |
| 3 | Three-Tier App (ALB/ASG/RDS) | Composition, CI/CD, real AWS topology |
| 4 | Platform in a Box (Capstone) | Governance, testing, state at scale |
| 5 *(stretch)* | Multi-account with AWS Organizations + assume-role | Enterprise IAM, provider aliasing |
| 6 *(stretch)* | Import a "legacy" clicked-together stack into TF | Real-world brownfield adoption |

---

## 4. Real-World Topics Interviewers Probe (Beyond the Syllabus)

These separate "passed a cert" from "ran this in production." Build a 2–3 sentence story for each:

- **State disasters & recovery:** corrupted state, lost state, two simultaneous applies, accidental `state rm`, state backend migration.
- **Blast radius & safety:** how you limit the damage one apply can do; why prod gets separate state; manual approval gates.
- **Drift:** detecting and reconciling out-of-band console changes; `ignore_changes` trade-offs.
- **Brownfield adoption:** importing existing clicked-together infra without downtime.
- **Module governance at scale:** versioning, breaking changes, a private registry, deprecation.
- **Secrets:** the full lifecycle, why they live in state, ephemeral/write-only, Secrets Manager/SSM integration.
- **Provider/Terraform upgrades:** handling breaking changes across many states.
- **CI/CD safety:** plan-on-PR, apply-on-merge, locking, who can apply.
- **Cost:** preventing the $10k surprise (NAT gateways, idle RDS, forgotten resources), infracost in CI.
- **Multi-account/multi-region:** provider aliases, assume-role, AWS Organizations.
- **Terraform's limits:** when NOT to use Terraform (imperative app deploys, fast-changing data), and reaching for Ansible/Helm/app pipelines instead.

---

## 5. Interview & Scenario Bank

> Practice these **out loud**. For scenarios, narrate your reasoning, name the trade-offs, and end with "here's what I'd actually do."

### Tier 1 — Junior / Fundamentals (rapid-fire)
1. What is Terraform and how does it differ from Ansible and CloudFormation?
2. Walk me through `init → plan → apply → destroy`.
3. What is state and why does Terraform need it?
4. Variable vs local vs output — when do you use each?
5. `count` vs `for_each` — which do you default to and why?
6. What does the `.terraform.lock.hcl` file do and should you commit it?
7. What's a data source? Give an example.
8. Explain `~>`, `>=`, and `=` version constraints.
9. What are the four `lifecycle` meta-arguments?
10. What's the difference between an update-in-place and a replace in plan output?

### Tier 2 — Mid-level
11. How do you structure code for dev/staging/prod? Workspaces or directories — defend your choice.
12. Why is state sensitive, and how do you protect it?
13. How do you handle secrets in Terraform without leaking them into state?
14. What's the difference between `terraform state mv`, `rm`, and `import`?
15. How do you safely rename a resource without destroying it?
16. Why are provisioners considered a last resort?
17. How do you pin and consume registry modules safely?
18. What's the modern declarative way to import existing resources?
19. How does remote state locking prevent corruption?
20. When would you reach for `-target`, and why is it a smell if you use it often?

### Tier 3 — Senior
21. Design a reusable VPC module — what inputs/outputs and defaults?
22. Two engineers run `apply` against the same state simultaneously. What happens, and how do you prevent it?
23. How do you detect and reconcile drift?
24. Walk me through a safe team CI/CD workflow for Terraform.
25. How do you split a monolithic state into multiple states with zero downtime?
26. How do you handle a provider major-version upgrade across 20 environments?
27. Explain ephemeral values / write-only attributes and the problem they solve.
28. How do you test a module? (`terraform test`, contract tests, examples.)
29. When is Terraform the *wrong* tool?
30. How do you wire outputs from one state into another? Trade-offs of `terraform_remote_state` vs SSM/parameter passing?

### Tier 4 — Staff / Architect
31. Design a self-service Terraform platform for 40 application teams. How do you balance autonomy vs guardrails?
32. How do you enforce policy (encryption, tagging, allowed instance types) across all applies organization-wide?
33. A junior accidentally ran `terraform state rm` on a production database and the next apply wants to create a new one. Walk me through your response, minute by minute.
34. How do you think about blast radius when designing state boundaries?
35. Pitch a module-versioning and deprecation strategy that won't break consumers.
36. How would you migrate a 2,000-resource clicked-together AWS account into Terraform incrementally?
37. Sentinel vs OPA vs tfsec — where does each fit in a governance strategy?
38. How do you keep Terraform runs fast and safe as the org scales to thousands of resources?
39. Make the build-vs-buy case: HCP Terraform vs self-hosted Atlantis vs raw CI.
40. What's your philosophy on monorepo vs polyrepo for Terraform, and state granularity?

### Scenario Deep-Dives (whiteboard-style — practice narrating full answers)
- **S1 — The Corrupted State:** A failed apply left state out of sync with reality (resource exists in AWS, gone from state). Diagnose and recover step by step.
- **S2 — The $40k Bill:** Someone left NAT gateways and an RDS Multi-AZ running in 6 regions. How does your Terraform setup prevent this, and how do you remediate now?
- **S3 — The Breaking Module:** You ship `v2.0.0` of the org VPC module with a breaking change. 30 teams consume it. What does your release/comms/versioning process look like?
- **S4 — The Drift Mystery:** A security group rule keeps reappearing after every apply. Walk through diagnosing whether it's drift, a sidecar process, or `ignore_changes` misuse.
- **S5 — Zero-Downtime Refactor:** Split one giant state into network/data/app states for a live production system. Sequence the steps.
- **S6 — Onboarding Legacy:** Import a 3-year-old hand-built VPC + EC2 fleet into Terraform without a single resource being recreated. Plan it.

---

## 6. HashiCorp Terraform Associate (004) — Cert Quick Facts

- **Version:** 004 (replaced 003 as of Jan 8, 2026), aligned to **Terraform 1.12**.
- **Format:** ~57–60 multiple-choice / true-false questions, **no hands-on labs**.
- **Passing:** pass/fail, roughly 70%.
- **Delivery:** online proctored.
- **Validity:** 2 years; renew by retaking or advancing to the Authoring & Operations Professional cert.
- **004-specific emphasis:** lifecycle/custom conditions (`precondition`/`postcondition`/`check`), refactoring blocks (`moved`/`removed`/`import`), sensitive data (ephemeral/write-only), and HCP Terraform projects. Drill these — they're the deltas from older study material.
- **Strategy:** the exam rewards precise CLI/command knowledge and definitions. Your hands-on projects cover the *understanding*; spend the last 2–3 days on *exact command behavior* trivia and practice exams.

---

## 7. Resource Guide

**Official (start here, free, exam-aligned):**
- HashiCorp Developer portal — "Get Started: AWS" track + the official 004 study guide and sample questions.
- Terraform docs — read the language reference for state, modules, functions, and the 004 blocks (`import`, `moved`, `removed`, `check`, ephemeral).
- Terraform Registry — read the source of `terraform-aws-modules/*` to learn pro module structure.

**Hands-on / labs:**
- Your own AWS sandbox (the best teacher — with that budget alert set).
- `terraform-aws-modules` GitHub org — read real production-grade modules.

**Practice exams (for cert week):** Use 2–3 reputable 004-aligned practice exam sets; treat every wrong answer as a study prompt. (Independent practice sites are fine for drilling, but anchor your *truth* to the official docs.)

**Tooling to learn by using:** `tflint`, `tfsec`/`trivy`, `terraform-docs`, `infracost`, `tfenv`/`mise`, GitHub Actions, HCP Terraform free tier.

**Books/communities (post-sprint depth):** *Terraform: Up & Running* (Yevgeniy Brikman) for production patterns; the Terraform subreddit and HashiCorp Discuss for real-world Q&A.

---

## 8. Progress Tracker

| Block | Status | Gate passed? |
|---|---|---|
| 0. Setup | ⬜ | |
| 1.1 HCL & core loop | ⬜ | |
| 1.2 Providers & data | ⬜ | |
| 1.3 Variables/outputs/locals | ⬜ | |
| 1.4 Functions & meta-args | ⬜ | |
| Project 1 | ⬜ | |
| 2.1 State deep dive | ⬜ | |
| 2.2 Modules | ⬜ | |
| 2.3 Multi-environment | ⬜ | |
| Project 2 | ⬜ | |
| 3.1 Provisioners/lifecycle | ⬜ | |
| 3.2 Conditions/checks/sensitive | ⬜ | |
| 3.3 Secrets & security | ⬜ | |
| 3.4 CI/CD | ⬜ | |
| Project 3 | ⬜ | |
| 4.1 State surgery | ⬜ | |
| 4.2 Testing & governance | ⬜ | |
| 4.3 Cert cram | ⬜ | |
| Project 4 (Capstone) | ⬜ | |

---

### Final note
The cert proves you *know* Terraform. The projects and scenario stories prove you can *run* it. Interviewers at senior/staff level are listening for trade-offs, blast-radius awareness, and recovery instincts — so for every concept, always be able to answer not just "how" but "why this and not that, and what breaks if you get it wrong."
