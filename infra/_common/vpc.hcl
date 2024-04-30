terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git//"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env = local.env_vars.locals.env
  region = local.env_vars.locals.region
  account_id = local.env_vars.locals.account_id
  vpc_cidr = local.env_vars.locals.vpc_cidr
  tags = local.env_vars.locals.tags
  // vpc_number = split(".", local.vpc_cidr)[1]

  azs = ["${local.region}a", "${local.region}b", "${local.region}c"]
}

generate "providers-common" {
  path = "providers-common.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "aws" {
  region = "${local.region}"

  allowed_account_ids = ["${local.account_id}"]
}
EOF
}

inputs = {
  name = local.env
  cidr = local.vpc_cidr
  azs  = local.azs

  private_subnets     = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  public_subnets      = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]
  database_subnets    = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 8)]

  enable_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true
  create_igw           = true

  tags = local.tags
}
