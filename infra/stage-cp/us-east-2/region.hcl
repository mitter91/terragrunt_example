locals {
  entity     = "cp"
  tier       = "stage"
  region     = "us-east-2"
  backend    = "${local.tier}-${local.entity}-${local.region}-tfstate"
  account_id = "027225766287"
}