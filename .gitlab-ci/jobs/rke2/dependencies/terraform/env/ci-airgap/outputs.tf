output "utility_ip" {
  value = data.terraform_remote_state.utility.outputs.utility_ip
}

output "vpc_cidr" {
  value = module.ci.vpc_cidr
}