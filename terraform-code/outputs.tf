output "clone-urls" {
  value       = { for i in github_repository.mtc-repo : i.name => [i.ssh_clone_url, i.http_clone_url] }
  description = "Repo names and clone urls"
  sensitive   = false
}