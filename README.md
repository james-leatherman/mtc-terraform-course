# MTC Terraform Project

This is a Terraform project that manages Github repos and associated readme files and Github pages. I created this during my [More than Certified](https://morethancertified.com/course/mtc-terraform) training, and it helped me understand the possibilities in control flow and templating in Terraform. It also allowed me to generate a Github pages landing where I could have my profile and a listing of the Github repos that were created with this project.

Version 1 of the project used a local state file, which is only recommended for local testing. Version 2 includes the abiltity to create [HCP Terraform](https://app.terraform.io/) resources and manage the state there.

## Project Structure

```plaintext

├── .gitignore
├── .terraform/
├── state/
├── terraform-code/
│   ├── .terraform/
│   ├── .terraform.lock.hcl
│   ├── backends.tf
│   ├── main.tf
│   ├── modules/
│   │   ├── deploy-keys/
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   ├── providers.tf
│   │   │   ├── variables.tf
│   │   ├── dev-repos/
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   ├── variables.tf
│   │   ├── info-page/
│   │       ├── main.tf
│   │       ├── outputs.tf
│   │       ├── variables.tf
│   ├── providers.tf
│   ├── templates/
├── hcp-code/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── datasources.tf
├── terraform.tfstate
```

## Modules

### `dev-repos`

This module creates repositories for different environments and languages.

- **Inputs:**
  - `env`: The deployment environment (`dev` or `prod`).
  - `repos_max`: Maximum number of repositories.
  - `repos`: Map of repository configurations.

- **Outputs:**
  - `clone_urls`: Map of repository names and their clone URLs.

### `deploy-keys`

This module generates and deploys SSH keys for the private dev repositories. It also manages cleanup of local keys once ```terraform destroy``` is called.

- **Inputs:**
  - `repo_name`: Name of the repository.

### `info-page`

This module generates a basic info page for each repository, with environment and language, in a standardized template.

- **Inputs:**
  - `repos`: Map of repository names and their clone URLs.


## Providers

- `github`: Used to manage GitHub resources.
- `tls`: Used to generate SSH keys.

## Backend

The state is stored locally in the [terraform.tfstate](http://_vscodecontentref_/5) file.

## Outputs

- `repo-info`: Map of repository names and their clone URLs.
- `repo-list`: List of repository names for the `dev` environment.

## License

This project is licensed under the MIT License.