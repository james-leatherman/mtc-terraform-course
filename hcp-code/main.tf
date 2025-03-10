# Providers

terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.64.0"
    }
  }
}

# Input Variables

variable "github_token" {
  description = "GitHub token to use for accessing repos"
  type        = string
  sensitive   = true
}

variable "tfe_token" {
  description = "Terraform Cloud token"
  type        = string
  sensitive   = true
}

# Provider

provider "tfe" {
  hostname = "app.terraform.io"
  token    = var.tfe_token
}

data "tfe_organization" "this" {
  name = "james-leatherman"
}

# Create and OAuth client for GitHub at the Organization level

resource "tfe_oauth_client" "this" {
  name                = "mtc-github-oauth-client"
  organization        = data.tfe_organization.this.name
  api_url             = "https://api.github.com"
  http_url            = "https://github.com"
  oauth_token         = var.github_token
  service_provider    = "github"
  organization_scoped = true
}

# Create Project

resource "tfe_project" "this" {
  name         = "mtc-portfolio"
  organization = data.tfe_organization.this.name
}

# Associate OAuth client with the project

resource "tfe_project_oauth_client" "this" {
  project_id      = tfe_project.this.id
  oauth_client_id = tfe_oauth_client.this.id
}

# Create Workspaces

resource "tfe_workspace" "mtc_repos" {
  name         = "mtc-repos"
  organization = data.tfe_organization.this.name
  project_id   = tfe_project.this.id

  working_directory     = "terraform-code/modules/repos"
  auto_apply            = true
  file_triggers_enabled = true
  trigger_patterns      = ["**/repos/**/*"]

  vcs_repo {
    identifier         = "james-leatherman/mtc-terraform-course"
    branch             = "cicd"
    ingress_submodules = false
    oauth_token_id     = tfe_oauth_client.this.oauth_token_id
  }
}

resource "tfe_workspace_run" "mtc_repos" {
  workspace_id = tfe_workspace.mtc_repos.id

  destroy {
    manual_confirm = false
    wait_for_run   = true
  }
}

resource "tfe_workspace_run" "mtc_info_page" {
  workspace_id = tfe_workspace.mtc_info_page.id
  depends_on   = [tfe_workspace_run.mtc_repos, tfe_workspace_settings.this]

  destroy {
    manual_confirm = false
    wait_for_run   = true
  }
}

resource "tfe_workspace" "mtc_info_page" {
  name         = "mtc-info-page"
  depends_on   = [tfe_workspace.mtc_repos]
  organization = data.tfe_organization.this.name
  project_id   = tfe_project.this.id

  working_directory      = "terraform-code/modules/info-page"
  auto_apply             = false
  file_triggers_enabled  = true
  trigger_patterns       = ["**/info-page/**/*"]
  auto_apply_run_trigger = true

  vcs_repo {
    identifier         = "james-leatherman/mtc-terraform-course"
    branch             = "cicd"
    ingress_submodules = false
    oauth_token_id     = tfe_oauth_client.this.oauth_token_id
  }
}

resource "tfe_workspace_settings" "this" {
  workspace_id              = tfe_workspace.mtc_repos.id
  remote_state_consumer_ids = [tfe_workspace.mtc_info_page.id]
}

# Create variables and variable set for the project

resource "tfe_variable" "mtc_repos_github_token" {
  key             = "GITHUB_TOKEN"
  value           = var.github_token
  category        = "env"
  sensitive       = true
  variable_set_id = tfe_variable_set.this.id
}

resource "tfe_variable_set" "this" {
  name              = "Github Token Set"
  description       = "Github resources for Deployments"
  organization      = data.tfe_organization.this.name
  parent_project_id = tfe_project.this.id
}

resource "tfe_project_variable_set" "this" {
  project_id      = tfe_project.this.id
  variable_set_id = tfe_variable_set.this.id
}

# Configure run trigger

resource "tfe_run_trigger" "mtc_repos_to_mtc_info_page" {
  sourceable_id = tfe_workspace.mtc_repos.id
  workspace_id  = tfe_workspace.mtc_info_page.id
}
