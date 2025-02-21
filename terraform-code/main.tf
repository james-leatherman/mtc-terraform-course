resource "github_repository" "mtc-repo" {
  for_each    = var.repos
  name        = "mtc-repo-${each.key}"
  description = "${each.value.lang} code for MTC"
  visibility  = var.env == "dev" ? "private" : "public"
  auto_init   = true
  /*   provisioner "local-exec" {
    command = "gh repo view ${self.name} --web"
  } */
  provisioner "local-exec" {
    command = "rm -rf ${self.name}"
    when    = destroy
  }
}

resource "terraform_data" "repo-clone" {
  for_each   = var.repos
  depends_on = [github_repository_file.index, github_repository_file.readme]

  provisioner "local-exec" {
    command = "gh repo clone ${github_repository.mtc-repo[each.key].name}"
  }
}

resource "github_repository_file" "readme" {
  for_each            = var.repos
  repository          = github_repository.mtc-repo[each.key].name
  branch              = "main"
  file                = "README.md"
  content             = "# This is the ${var.env} ${each.value.lang} repo for ${each.key} developers"
  overwrite_on_create = true
}

resource "github_repository_file" "index" {
  for_each            = var.repos
  repository          = github_repository.mtc-repo[each.key].name
  branch              = "main"
  file                = each.value.filename
  content             = "# Hello ${each.value.lang}!"
  overwrite_on_create = true
}

output "clone-urls" {
  value       = { for i in github_repository.mtc-repo : i.name => [i.ssh_clone_url, i.http_clone_url] }
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