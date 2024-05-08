terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-efs.git//"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env = local.env_vars.locals.env
  region = local.env_vars.locals.region
  account_id = local.env_vars.locals.account_id
  tags = local.env_vars.locals.tags
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

dependency "vpc" {
  config_path = "../../../../dev-cp/us-east-1/playground/vpc"
  mock_outputs = {
    vpc_id          = "vpc-xxxxxxxx"
    azs             = ["xx-central-1x","yy-central-1y","zz-central-1z"]
    private_subnets = ["subnet-xxxxxxxx","subnet-yyyyyyyy","subnet-zzzzzzzz"]
    private_subnets_cidr_blocks = ["xxx.xxx.xxx.xxx/xx","yyy.yyy.yyy.yyy/yy","zzz.zzz.zzz.zzz/zz"]
  }
}

inputs = {
  name             = local.env
  creation_token   = local.env
  encrypted        = true
  performance_mode = "generalPurpose"

  mount_targets = { for k, v in zipmap(
    dependency.vpc.outputs.azs, dependency.vpc.outputs.private_subnets) : k => { subnet_id = v } }

  security_group_name        = "${local.env}-efs"
  security_group_description = "${local.env} EFS security group"
  security_group_vpc_id      = dependency.vpc.outputs.vpc_id
  security_group_rules = {
    vpc = {
      # relying on the defaults provdied for EFS/NFS (2049/TCP + ingress)
      description = "NFS ingress from VPC private subnets"
      cidr_blocks = dependency.vpc.outputs.private_subnets_cidr_blocks
    }
  }

  enable_backup_policy = false

  create_replication_configuration = false

  tags = local.tags
}