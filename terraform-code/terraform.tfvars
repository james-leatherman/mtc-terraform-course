repos_max = 3
env       = "dev"
repos = {
  infra = {
    lang     = "terraform"
    filename = "main.tf"
  },
  backend = {
    lang     = "python"
    filename = "main.py"
  },
  frontend = {
    lang     = "html"
    filename = "index.html"
  }
}