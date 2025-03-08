# terraform {
#   backend "local" {
#     path = "../state/terraform.tfstate"
#   }
# }

terraform {
  cloud {

    organization = "james-leatherman"

    workspaces {
      name = "dev"
    }
  }
}