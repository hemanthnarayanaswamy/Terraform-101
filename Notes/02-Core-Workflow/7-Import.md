# terraform import

`terraform import` allows Terraform to start managing infrastructure that already exists.

```text
Existing Resource
       ↓
terraform import
       ↓
Terraform State
       ↓
Terraform Management
```

It does **not create resources**.

Instead, it connects an existing resource to Terraform state.

---

## Why Do We Need Import?
Terraform usually creates resources itself.

But sometimes resources already exist:
```text
Created manually
Created from Console
Created by another team
Created before Terraform adoption
```
Terraform doesn't know about them.

`terraform import` solves this problem.
-  Reads Existing Resource
- Associates Resource
- Stores Mapping in State

After that resource created manually become part of state which will be terraform managed. 

## Import Workflow

1. Check Infrastructure already exists.
2. Create Terraform configuration.
    - Create a temporary file (e.g., `imports.tf`) and write an import block pointing to your existing cloud resource. 
    - You need to provide the target Terraform resource address (to) and the unique cloud provider ID (id)
```hcl
import {
  to = aws_instance.web_server
  id = "i-0abcdef1234567890"  # Your actual AWS Instance ID
}
```
3. Run the `terraform plan` command with the `-generate-config-out` flag. This directs Terraform to connect to your cloud provider, inspect the existing resource, and automatically write the matching HCL block to a new file.
4. Open the newly created `generated.tf` file. Terraform will output all attributes of the resource, including read-only and default values.Action: Clean up the file by removing unnecessary arguments (like auto-generated IDs or default VPC settings) so the code stays readable and maintainable
5. Run a standard `terraform apply`. Terraform will map the real-world infrastructure into your terraform.tfstate file.

**Note:** This operation is state-only; it will not modify or recreate your live infrastructure. *Once complete, you can safely delete or keep the import file.*

### Declarative Block vs. Legacy CLI Command

<table class="NRefec" data-animation-nesting=""><tbody><tr class="cZCYO" data-sfc-cp="" jsaction="" jscontroller="OkanJc#hv5sFd" data-sfc-root="ep" jsuid="iu5Vo_4v" data-complete="true"><th class="iry6k" style="" colspan="undefined" data-sfc-cp="" jsaction="" jscontroller="uuu13#x1Xdt" data-sfc-root="ep" jsuid="iu5Vo_4w" data-complete="true">Feature<!--TgQPHd|||[]--></th><th class="iry6k" style="" colspan="undefined" data-sfc-cp="" jsaction="" jscontroller="uuu13#x1Xdt" data-sfc-root="ep" jsuid="iu5Vo_4x" data-complete="true"><code dir="ltr" class="KDcb0c" jsaction="" jscontroller="hNviFe#redMub" data-sfc-root="ep" jsuid="iu5Vo_4y" data-complete="true">import<!--TgQPHd|||[]--></code> Block (Modern) 🌟<!--TgQPHd|||[]--></th><th class="iry6k" style="" colspan="undefined" data-sfc-cp="" jsaction="" jscontroller="uuu13#x1Xdt" data-sfc-root="ep" jsuid="iu5Vo_4z" data-complete="true"><code dir="ltr" class="KDcb0c" jsaction="" jscontroller="hNviFe#redMub" data-sfc-root="ep" jsuid="iu5Vo_50" data-complete="true">terraform import<!--TgQPHd|||[]--></code> CLI (Legacy)<!--TgQPHd|||[]--></th><!--TgQPHd|||[]--></tr><tr class="cZCYO" data-sfc-cp="" jsaction="" jscontroller="OkanJc#hv5sFd" data-sfc-root="ep" jsuid="iu5Vo_51" data-complete="true"><td class="cOeeGf" style="" colspan="undefined" data-sfc-cp="" jsaction="" jscontroller="QYassd#cLglr" data-sfc-root="ep" jsuid="iu5Vo_52" data-complete="true"><strong class="rQesXe MPyX" data-sfc-cp="" jsaction="" jscontroller="tP2kf#s32ZS" data-sfc-root="ep" jsuid="iu5Vo_53" data-complete="true">Workflow Type<!--TgQPHd|||[]--></strong><!--TgQPHd|||[]--></td><td class="cOeeGf" style="" colspan="undefined" data-sfc-cp="" jsaction="" jscontroller="QYassd#cLglr" data-sfc-root="ep" jsuid="iu5Vo_54" data-complete="true">Declarative (Code-first)<!--TgQPHd|||[]--></td><td class="cOeeGf" style="" colspan="undefined" data-sfc-cp="" jsaction="" jscontroller="QYassd#cLglr" data-sfc-root="ep" jsuid="iu5Vo_55" data-complete="true">Imperative (Command-line first)<!--TgQPHd|||[]--></td><!--TgQPHd|||[]--></tr><tr class="cZCYO" data-sfc-cp="" jsaction="" jscontroller="OkanJc#hv5sFd" data-sfc-root="ep" jsuid="iu5Vo_56" data-complete="true"><td class="cOeeGf" style="" colspan="undefined" data-sfc-cp="" jsaction="" jscontroller="QYassd#cLglr" data-sfc-root="ep" jsuid="iu5Vo_57" data-complete="true"><strong class="rQesXe MPyX" data-sfc-cp="" jsaction="" jscontroller="tP2kf#s32ZS" data-sfc-root="ep" jsuid="iu5Vo_58" data-complete="true">Code Generation<!--TgQPHd|||[]--></strong><!--TgQPHd|||[]--></td><td class="cOeeGf" style="" colspan="undefined" data-sfc-cp="" jsaction="" jscontroller="QYassd#cLglr" data-sfc-root="ep" jsuid="iu5Vo_59" data-complete="true"><strong class="rQesXe MPyX" data-sfc-cp="" jsaction="" jscontroller="tP2kf#s32ZS" data-sfc-root="ep" jsuid="iu5Vo_5a" data-complete="true">Automatic<!--TgQPHd|||[]--></strong> via <code dir="ltr" class="KDcb0c" jsaction="" jscontroller="hNviFe#redMub" data-sfc-root="ep" jsuid="iu5Vo_5b" data-complete="true">-generate-config-out<!--TgQPHd|||[]--></code><!--TgQPHd|||[]--></td><td class="cOeeGf" style="" colspan="undefined" data-sfc-cp="" jsaction="" jscontroller="QYassd#cLglr" data-sfc-root="ep" jsuid="iu5Vo_5c" data-complete="true"><strong class="rQesXe MPyX" data-sfc-cp="" jsaction="" jscontroller="tP2kf#s32ZS" data-sfc-root="ep" jsuid="iu5Vo_5d" data-complete="true">Manual<!--TgQPHd|||[]--></strong>. You must write HCL first.<!--TgQPHd|||[]--></td><!--TgQPHd|||[]--></tr><tr class="cZCYO" data-sfc-cp="" jsaction="" jscontroller="OkanJc#hv5sFd" data-sfc-root="ep" jsuid="iu5Vo_5e" data-complete="true"><td class="cOeeGf" style="" colspan="undefined" data-sfc-cp="" jsaction="" jscontroller="QYassd#cLglr" data-sfc-root="ep" jsuid="iu5Vo_5f" data-complete="true"><strong class="rQesXe MPyX" data-sfc-cp="" jsaction="" jscontroller="tP2kf#s32ZS" data-sfc-root="ep" jsuid="iu5Vo_5g" data-complete="true">State Impact<!--TgQPHd|||[]--></strong><!--TgQPHd|||[]--></td><td class="cOeeGf" style="" colspan="undefined" data-sfc-cp="" jsaction="" jscontroller="QYassd#cLglr" data-sfc-root="ep" jsuid="iu5Vo_5h" data-complete="true">Safe. Previews changes via <code dir="ltr" class="KDcb0c" jsaction="" jscontroller="hNviFe#redMub" data-sfc-root="ep" jsuid="iu5Vo_5i" data-complete="true">plan<!--TgQPHd|||[]--></code> first.<!--TgQPHd|||[]--></td><td class="cOeeGf" style="" colspan="undefined" data-sfc-cp="" jsaction="" jscontroller="QYassd#cLglr" data-sfc-root="ep" jsuid="iu5Vo_5j" data-complete="true">Immediate modification of state file.<!--TgQPHd|||[]--></td><!--TgQPHd|||[]--></tr><tr class="cZCYO" data-sfc-cp="" jsaction="" jscontroller="OkanJc#hv5sFd" data-sfc-root="ep" jsuid="iu5Vo_5k" data-complete="true"><td class="cOeeGf" style="" colspan="undefined" data-sfc-cp="" jsaction="" jscontroller="QYassd#cLglr" data-sfc-root="ep" jsuid="iu5Vo_5l" data-complete="true"><strong class="rQesXe MPyX" data-sfc-cp="" jsaction="" jscontroller="tP2kf#s32ZS" data-sfc-root="ep" jsuid="iu5Vo_5m" data-complete="true">CI/CD Friendly<!--TgQPHd|||[]--></strong><!--TgQPHd|||[]--></td><td class="cOeeGf" style="" colspan="undefined" data-sfc-cp="" jsaction="" jscontroller="QYassd#cLglr" data-sfc-root="ep" jsuid="iu5Vo_5n" data-complete="true">Yes, runs perfectly in automated pipelines.<!--TgQPHd|||[]--></td><td class="cOeeGf" style="" colspan="undefined" data-sfc-cp="" jsaction="" jscontroller="QYassd#cLglr" data-sfc-root="ep" jsuid="iu5Vo_5o" data-complete="true">No, requires interactive local execution.<!--TgQPHd|||[]--></td><!--TgQPHd|||[]--></tr><tr class="cZCYO" data-sfc-cp="" jsaction="" jscontroller="OkanJc#hv5sFd" data-sfc-root="ep" jsuid="iu5Vo_5p" data-complete="true"><td class="cOeeGf" style="" colspan="undefined" data-sfc-cp="" jsaction="" jscontroller="QYassd#cLglr" data-sfc-root="ep" jsuid="iu5Vo_5q" data-complete="true"><strong class="rQesXe MPyX" data-sfc-cp="" jsaction="" jscontroller="tP2kf#s32ZS" data-sfc-root="ep" jsuid="iu5Vo_5r" data-complete="true">Bulk Imports<!--TgQPHd|||[]--></strong><!--TgQPHd|||[]--></td><td class="cOeeGf" style="" colspan="undefined" data-sfc-cp="" jsaction="" jscontroller="QYassd#cLglr" data-sfc-root="ep" jsuid="iu5Vo_5s" data-complete="true">Supported (using <code dir="ltr" class="KDcb0c" jsaction="" jscontroller="hNviFe#redMub" data-sfc-root="ep" jsuid="iu5Vo_5t" data-complete="true">for_each<!--TgQPHd|||[]--></code> loops).<!--TgQPHd|||[]--></td><td class="cOeeGf" style="" colspan="undefined" data-sfc-cp="" jsaction="" jscontroller="QYassd#cLglr" data-sfc-root="ep" jsuid="iu5Vo_5u" data-complete="true">No, requires writing custom bash scripts.<!--TgQPHd|||[]--></td><!--TgQPHd|||[]--></tr></tbody></table>


## Important Rule: Configuration Must Match Reality

Actual Bucket `Location = US`, Terraform Import block configuration: `location = "EU"`

After import, if we apply `terraform plan`, Terraform wants to modify bucket because configuration differs from actual infrastructure.

## Common Errors

1. Resource Does Not Exist
2. Wrong Resource Type
3. Authentication Error
4. Missing Resource Block in Import configuration.


***Interview Keywords:***
```text
State Management
Existing Infrastructure
Resource Adoption
Terraform Migration
Infrastructure as Code
```