locals {
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  region = local.region_vars.locals.region
  account_id = local.region_vars.locals.account_id
  unit = "playground"
  env = "${local.region_vars.locals.tier}-${local.region_vars.locals.entity}-${local.unit}"
  vpc_cidr = "10.10.0.0/16"

  tags = {
    Environment = local.env
    Tier = local.region_vars.locals.tier
    Entity = local.region_vars.locals.entity
    Unit = local.unit
    Region = local.region
    Terraform = true
  }
}
