variable "deploy_key" {
  description = "Choice to deploy keys"
  type        = bool
  default     = false
}

variable "environments" {
  description = "List of environments"
  type        = set(string)
  default     = ["dev", "prod"]
}
