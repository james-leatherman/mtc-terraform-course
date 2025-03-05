resource "github_repository" "mtc-repo" {
  for_each    = var.repos
  name        = "mtc-${each.key}-${var.env}"
  description = "${each.value.lang} code for MTC"
  visibility  = var.env == "dev" ? "private" : "public"
  auto_init   = true
  dynamic "pages" {
    for_each = each.value.pages && var.env != "dev" ? [1] : []
    content {
      source {
        branch = "main"
        path   = "/"
      }
    }
  }

  provisioner "local-exec" {
    command = var.run_provisioners ? "gh repo view ${self.name} --web" : "echo 'Skip repo view'"
  }

  provisioner "local-exec" {
    command = "rm -rf ${self.name}"
    when    = destroy
  }
}

resource "terraform_data" "repo-clone" {
  for_each   = var.repos
  depends_on = [github_repository_file.main, github_repository_file.readme]

  provisioner "local-exec" {
    command = var.run_provisioners ? "gh repo clone ${github_repository.mtc-repo[each.key].name}" : "echo 'Skip repo clone'"
  }
}

resource "github_repository_file" "readme" {
  for_each   = var.repos
  repository = github_repository.mtc-repo[each.key].name
  branch     = "main"
  file       = "README.md"
  content = templatefile("${path.module}/templates/readme.tftpl", {
    env    = var.env,
    lang   = each.value.lang,
    repo   = each.key,
    author = data.github_user.current.name
  })
  overwrite_on_create = true
}

resource "github_repository_file" "main" {
  for_each            = var.repos
  repository          = github_repository.mtc-repo[each.key].name
  branch              = "main"
  file                = each.value.filename
  content             = "# Hello ${each.value.lang}!"
  overwrite_on_create = true
  lifecycle {
    ignore_changes = [
      content,
    ]
  }
}

variable "env" {
  type        = string
  description = "Deploy environment"
  validation {
    condition     = contains(["dev", "prod"], var.env)
    error_message = "Env must be 'dev' or 'prod'"
  }
}