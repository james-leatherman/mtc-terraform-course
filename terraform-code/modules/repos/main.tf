module "repos" {
  source    = "./modules/dev-repos"
  for_each  = var.environments
  repos_max = 10
  env       = each.key
  repos            = { for v in csvdecode(file("repos.csv")) : v["environment"] => { for x, y in v : x => lower(y) } }
  run_provisioners = false
}

module "deploy-keys" {
  for_each  = var.deploy_key ? toset(flatten([for k, v in module.repos : keys(v.clone_urls) if k == "dev"])) : []
  source    = "./modules/deploy-keys"
  repo_name = each.key
}

output "repo-info" {
  value = { for k, v in module.repos : k => v.clone_urls }
}

output "repo-list" {
  value = flatten([for k, v in module.repos : keys(v.clone_urls) if k == "dev"])
}

output "clone_urls" {
  value = module.repos
}