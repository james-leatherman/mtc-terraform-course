variable "repo_count" {
  type        = number
  description = "Number of repos"
  default     = 1


  validation {
    condition     = var.repo_count < 5
    error_message = "No more than 5"
  }
}
