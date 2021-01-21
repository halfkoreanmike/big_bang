provider "aws" {
  region = "us-gov-west-1"
}

data "terraform_remote_state" "networking" {
  backend = "local"
  config = {
    path = "../../../../../networking/aws/dependencies/terraform/env/dev/terraform.tfstate"
  }
}

module "dev" {
  source = "../../main"
  env      = "tunde-dev"
  vpc_id    = data.terraform_remote_state.networking.outputs.vpc_id
  subnet_id = data.terraform_remote_state.networking.outputs.private_subnets[0]
  pkg_s3_bucket = "umbrella-bigbang-airgap"
  pkg_path = "umbrella/BB-1073"
}
