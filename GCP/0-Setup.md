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