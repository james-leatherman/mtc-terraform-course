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
    command = "gh repo view ${self.name} --web"
  }
}

data "github_user" "current" {
  username = ""
}

resource "github_repository_file" "this" {
  repository          = github_repository.this.name
  branch              = "main"
  file                = "index.md"
  overwrite_on_create = true
  content = templatefile("${path.module}/templates/index.tftpl", {
    avatar = data.github_user.current.avatar_url,
    name   = data.github_user.current.name,
    date   = formatdate("YYYY", timestamp())
  })
}