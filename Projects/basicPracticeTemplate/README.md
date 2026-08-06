# Module 2 - First GCP Resource

This is a beginner Terraform project for Google Cloud.

It creates:

- The Cloud Storage API enablement resource
- One Cloud Storage bucket

## Steps

Copy the example variable file:

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
project_id  = "your-gcp-project-id"
bucket_name = "your-globally-unique-bucket-name"
```

Run the workflow:

```powershell
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

When finished practicing, destroy the resource:

```powershell
terraform destroy
```

## Notes

- GCS bucket names are globally unique.
- Do not commit `terraform.tfvars`, `.terraform/`, or `.tfstate` files.
- If API enablement fails, make sure the Service Usage API is enabled in your GCP project.
