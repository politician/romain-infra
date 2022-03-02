# Github runner for domains repo
module "gh_runner_domains" {
  source       = "./modules/do-gh-runner"
  ssh_key      = "f8:6b:7b:4e:24:42:a9:9b:05:ec:94:53:b6:6c:27:f8"
  runner_scope = "politician/domains"
  runner_token = "AAYCM4BU5MNJKKSYOIYH2WDCD5KGA"
}

output "gh_runner_domains_ips" {
  value = module.gh_runner_domains.ips
}
