locals {
  repos = {
    infra = {
      lang     = "terraform"
      filename = "main.tf"
      pages    = true
    },
    backend = {
      lang     = "python"
      filename = "main.py"
      pages    = true
    },
    frontend = {
      lang     = "javascript"
      filename = "index.js"
      pages    = true
    }
  }
  environments = toset(["dev", "prod"])
}

module "repos" {
  source    = "./modules/dev-repos"
  for_each  = local.environments
  env       = each.key
  repos_max = 10
  repos     = local.repos
}

module "deploy-keys" {
  for_each  = toset(flatten([for k, v in module.repos : keys(v.clone-urls) if k == "dev"]))
  source    = "./modules/deploy-keys"
  repo_name = each.key
}

module "info-page" {
  source = "./modules/info-page"
  repos = { for k,v in module.repos["prod"].clone-urls : k => v }
}

output "repo-info" {
  value = { for k, v in module.repos : k => v.clone-urls }
}

output "repo-list" {
  value = flatten([for k, v in module.repos : keys(v.clone-urls) if k == "dev"])
}