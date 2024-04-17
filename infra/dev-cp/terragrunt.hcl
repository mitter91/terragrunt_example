locals {
  region_vars   = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  backend       = local.region_vars.locals.backend
  region        = local.region_vars.locals.region
  account_id    = local.region_vars.locals.account_id
  iam_role_name = get_env("IAM_ROLE_NAME", "PlatformAutomationAccess")
  iam_role_arn  = "arn:aws:iam::${local.account_id}:role/${local.iam_role_name}"
  fix = "fix"
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