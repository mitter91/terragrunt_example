terraform {
  source = "git::https://git.coinspaid.cloud/infra/tf-modules-group/tf-efs.git//?ref=cp1.0.0"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env = local.env_vars.locals.env
  tags = local.env_vars.locals.tags
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id          = "vpc-xxxxxxxx"
    azs             = ["xx-central-1x","yy-central-1y","zz-central-1z"]
    private_subnets = ["subnet-xxxxxxxx","subnet-yyyyyyyy","subnet-zzzzzzzz"]
    private_subnets_cidr_blocks = ["xxx.xxx.xxx.xxx/xx","yyy.yyy.yyy.yyy/yy","zzz.zzz.zzz.zzz/zz"]
  }
}

dependencies {
  paths = ["../vpc"]
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