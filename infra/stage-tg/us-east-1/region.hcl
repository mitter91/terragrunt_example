locals {
  entity     = "tg"
  tier       = "stage"
  region     = "us-east-1"
  backend    = "${local.tier}-${local.entity}-${local.region}-tfstate"
  account_id = "027225766287"
}