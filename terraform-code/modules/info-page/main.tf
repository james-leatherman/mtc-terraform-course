data "terraform_remote_state" "repos" {
  backend = "remote"
  config = {
    organization = "james-leatherman"
    workspaces = {
      name = "mtc-repos"
    }
  }
}

locals {
  repos = { for k, v in data.terraform_remote_state.repos.outputs.clone_urls["prod"].clone_urls : k => v }
}

resource "github_repository" "this" {
  name        = "mtc-info-page"
  description = "Repository info for MTC"
  visibility  = "public"
  auto_init   = true
  pages {
    source {
      branch = "main"
      path   = "/"
    }
  }

  provisioner "local-exec" {
    command = var.run_provisioners ? "gh repo view ${self.name} --web" : "echo 'Skip repo view'"
  }
}

data "github_user" "current" {
}

resource "time_static" "this" {}

resource "github_repository_file" "this" {
  repository          = github_repository.this.name
  branch              = "main"
  file                = "index.md"
  overwrite_on_create = true
  content = templatefile("${path.module}/templates/index.tftpl", {
    avatar = data.github_user.current.avatar_url,
    name   = data.github_user.current.name,
    date   = time_static.this.year,
    repos  = local.repos
  })
}