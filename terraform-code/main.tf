locals {
  repos = {
    infra = {
      lang     = "terraform"
      filename = "main.tf"
      pages    = false
    },
    backend = {
      lang     = "python"
      filename = "main.py"
      pages    = false
    },
    frontend = {
      lang     = "html"
      filename = "index.html"
      pages    = false
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

output "repo-info" {
  value = {for k,v in module.repos : k => v.clone-urls}
}