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
  depends_on = [github_repository_file.main, github_repository_file.readme]

  provisioner "local-exec" {
    command = "gh repo clone ${github_repository.mtc-repo[each.key].name}"
  }
}

resource "github_repository_file" "readme" {
  for_each   = var.repos
  repository = github_repository.mtc-repo[each.key].name
  branch     = "main"
  file       = "README.md"
  content = templatefile("templates/readme.tftpl", {
    env    = var.env,
    lang   = each.value.lang,
    repo   = each.key,
    author = data.github_user.current.name
  })
  /*   content             = <<-EOT
                        # This is the ${var.env} ${each.value.lang} repo for ${each.key} developers.
                        Last modified: ${data.github_user.current.name}
                        EOT */
  overwrite_on_create = true
  /*   lifecycle {
    ignore_changes = [
      content,
    ]
  } */
}

# moved {
#   from = github_repository_file.index
#   to   = github_repository_file.main
# }

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