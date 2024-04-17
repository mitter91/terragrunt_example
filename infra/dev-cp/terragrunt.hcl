locals {
  // region_vars   = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  // backend       = local.region_vars.locals.backend
  // region        = local.region_vars.locals.region
  // account_id    = local.region_vars.locals.account_id
  // iam_role_name = get_env("IAM_ROLE_NAME", "PlatformAutomationAccess")
  // iam_role_arn  = "arn:aws:iam::${local.account_id}:role/${local.iam_role_name}"
}



remote_state {
  backend = "s3"
  config = {
    bucket         = "dev-cp-us-east-1-tfstate"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}