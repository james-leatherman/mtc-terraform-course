variable "repos_max" {
  type        = number
  description = "Number of repos"
  default     = 2
  validation {
    condition     = var.repos_max <= 10
    error_message = "Repo count must be less than 11"
  }
}

variable "repos" {
  type        = map(map(string))
  description = "Repository name"
  validation {
    condition     = length(var.repos) <= var.repos_max
    error_message = "Too many repos and there's still not enough MCs"
  }
}