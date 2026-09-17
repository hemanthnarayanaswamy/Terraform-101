# `terraform validate`

`terraform validate` checks whether Terraform configuration files are syntactically valid and internally consistent.
- It verifies the configuration before Terraform creates an execution plan.

## Why Use terraform validate?

Before Terraform can create infrastructure, it needs to ensure:
- Syntax is correct
- References are valid
- Resource blocks are structured correctly
- Variable types make sense

## What Does validate Check?

1. **Syntax Validation** Checks Terraform syntax.
2. **Resource Configuration** Checks block structure. Terraform verifies required arguments.
3. **References** Checks references exist somewhere in the configuration.
4. **Variable Types** Checks compatibility. Validation detects type mismatch.
5. **Module Configuration** Checks module blocks. Terraform verifies configuration structure.


## Best Practices

1. Always Run validate Before plan
2. Use in *CI/CD*,  Every pull request should run: `terraform validate`
3. Run After Major Changes
4. Combine with fmt
```bash
terraform fmt
terraform validate
```

***Interview Keywords:***

```ini
Syntax Checking
Configuration Validation
Reference Validation
Type Checking
CI/CD Validation
Pre-Deployment Check
```
---
---

# `terraform fmt` Code Formatting

`terraform fmt` automatically formats Terraform configuration files according to Terraform's standard style guide. 
- It improves readability and consistency.

Benefits:
- Consistent formatting
- Easier code reviews
- Cleaner Git diffs
- Team standardization

## What Does terraform fmt Do?

1. Aligns Attributes
2. Fixes Indentation
3. Adds Consistent Spacing
4. Formats Nested Blocks

> In *CI/CD* Workflow in Pull Request `terraform fmt -check`. If formatting fails pipeline fails. Developer must run: `terraform fmt` and commit changes.

# Common Errors

## Running from Wrong Directory and Forgetting Recursive Formatting

```bash
terraform fmt
# outside Terraform project.
# No .tf files found


modules/
network/
gke/

terraform fmt
# Only current directory gets formatted.


terraform fmt -recursive
# For Recursive Formatting
```