locals {
  entity     = "tg"
  tier       = "dev"
  region     = "us-west-1"
  backend    = "${local.tier}-${local.entity}-${local.region}-tfstate"
  account_id = "027225766287"
}