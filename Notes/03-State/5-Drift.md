# Drift

Drift occurs when actual infrastructure differs from Terraform's expected state.

`Terraform Configuration = Terraform State ≠ Real Infrastructure`

When reality differs from what Terraform expects: ***Drift Exists***

Terraform expects infrastructure changes to be made through Terraform. However, changes may be made outside Terraform:
- Cloud Console
- CLI Commands
- Automation Scripts
- Other Teams
- Manual Updates

These changes create drift.

---

## Drift Detection

Terraform detects drift during:

```bash
terraform plan

# Reads Configuration
#        ↓
# Reads State
#        ↓
# Queries Provider
#        ↓
# Compares Reality

terraform plan -refresh-only
```
Purpose:
- Update State
- Without Modifying Infrastructure

---

### Resolving Drift

There are three common approaches.

#### Option 1: Revert Infrastructure
Keep Terraform configuration unchanged. Terraform restores infrastructure.
    * run `terraform apply`, terraform reverts the infrastructure to match the configuration.

#### Option 2: Update Terraform Configuration
Manual infrastructure code change to match the real infrastructure. 

#### Option 3: Ignore Drift
A very important drift-related feature. 

```hcl
lifecycle {
  ignore_changes = [
    labels
  ]
}
```
Terraform ignores: *Label Changes* but still manages everything else.. Useful when: **Another system manages labels**

---

## Refreshing State
Terraform can synchronize state with reality.

```bash
terraform plan -refresh-only
terraform apply -refresh-only
```

Purpose:
- Update State
- Without Infrastructure Changes

---

## Preventing Drift

1. Use Terraform For All Changes
2. Restrict Console Access
3. Use CI/CD Pipelines
4. Review Plans Regularly

---

## Drift vs State Corruption

1. ***Drift***: Actual cloud infrastructure changes outside of Terraform (such as a manual update in an AWS console), leaving the Terraform State File out of sync with reality.
    * **Cause**: Manual interventions, hotfixes applied directly via cloud provider dashboards, or out-of-band automation.
    * **Impact**: Terraform functions normally, but a terraform plan will propose overwriting the manual changes to match your original HCL configuration.

2. ***State Corruption***: The state itself becomes structurally invalid or wrong, meaning Terraform can no longer parse or read it. **Broken `terraform.tfstate`.
    * **Cause**: Concurrent un-locked writes from multiple teammates, interrupted apply operations, or accidental manual edits to the raw JSON state.
    * **Impact**: Terraform operations lock up or fail completely, blocking any ability to plan, apply, or destroy resources
    * **How to fix**: Restore the state file using remote backend version history (like S3 versioning), pull a healthy backup via terraform state pull, or re-import unmanaged resources

---

***Interview Keywords:***
```text
Infrastructure Drift
Configuration Mismatch
Manual Changes
State Refresh
ignore_changes
Drift Detection
```