module "repos" {
  source    = "./modules/dev-repos"
  for_each  = var.environments
  env       = each.key
  repos_max = 10
  repos     = local.repos
}

module "deploy-keys" {
  for_each  = var.deploy_key ? toset(flatten([for k, v in module.repos : keys(v.clone-urls) if k == "dev"])) : []
  source    = "./modules/deploy-keys"
  repo_name = each.key
}

module "info-page" {
  source = "./modules/info-page"
  repos  = { for k, v in module.repos["prod"].clone-urls : k => v }
}

output "repo-info" {
  value = { for k, v in module.repos : k => v.clone-urls }
}

output "repo-list" {
  value = flatten([for k, v in module.repos : keys(v.clone-urls) if k == "dev"])
}