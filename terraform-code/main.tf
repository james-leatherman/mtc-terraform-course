resource "github_repository" "mtc-repo" {
  for_each    = toset(["dev", "prod"])
  name        = "mtc-repo-${each.key}"
  description = "${each.value} code for MTC"
  visibility  = var.env == "dev" ? "private" : "public"
  auto_init   = true
}

resource "github_repository_file" "readme" {
  count               = var.repo_count
  repository          = github_repository.mtc-repo[count.index].name
  branch              = "main"
  file                = "README.md"
  content             = "# This is the ${var.env} repo for infra developers"
  overwrite_on_create = true
}

resource "github_repository_file" "index" {
  count               = var.repo_count
  repository          = github_repository.mtc-repo[count.index].name
  branch              = "main"
  file                = "index.html"
  content             = "Hello Terraform!"
  overwrite_on_create = true
}

output "clone-urls" {
  value       = { for i in github_repository.mtc-repo : i.name => i.http_clone_url }
  description = "Repo names and clone urls"
  sensitive   = false
}

variable "env" {
  type        = string
  description = "Deploy environment"
  validation {
    condition     = contains(["dev", "prod"], var.env)
    error_message = "Env must be 'dev' or 'prod'"
  }
}