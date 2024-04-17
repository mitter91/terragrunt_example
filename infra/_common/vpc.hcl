terraform {
  source = "terraform-aws-modules/vpc/aws"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env = local.env_vars.locals.env
  region = local.env_vars.locals.region
  vpc_cidr = local.env_vars.locals.vpc_cidr
  tags = local.env_vars.locals.tags
  // vpc_number = split(".", local.vpc_cidr)[1]

  azs = ["${local.region}a", "${local.region}b", "${local.region}c"]
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

  // create_vpce_s3       = true

// USAGE

//   tgw_share_accept       = true
//   tgw_resource_share_arn = dependency.net_ew1_tgw_sharing_requester.outputs.resource_share_arn
//   tgw_vpc_attachment = true
//   tgw_id             = 
//   tgw_allocation_subnet_key = "private"
//   route53_zone_ids       = dependency.coinspaid_local_zone.outputs.zone_ids
//   public_subnets = {
//     public = {
//       cidrs = [
//         "10.${local.vpc_number}.0.0/24",
//         "10.${local.vpc_number}.1.0/24",
//         "10.${local.vpc_number}.2.0/24",
//       ]
//       tags = {
//         "kubernetes.io/role/elb" = 1
//       }
//     }
//     public-2 = {
//       subnet_suffix = "public-2"
//       cidrs = [
//         "10.${local.vpc_number}.6.0/24",
//         "10.${local.vpc_number}.7.0/24",
//         "10.${local.vpc_number}.8.0/24"
//       ]
//       tags = {
//         "kubernetes.io/role/elb" = 1
//       }
//     }
//   }
//   private_subnets = {
//     private = {
//       subnet_suffix = "private"
//       cidrs = [
//         "10.${local.vpc_number}.10.0/24",
//         "10.${local.vpc_number}.11.0/24",
//         "10.${local.vpc_number}.12.0/24",
//         "10.${local.vpc_number}.13.0/24",
//         "10.${local.vpc_number}.14.0/24",
//         "10.${local.vpc_number}.15.0/24"
//       ]
//       tags = {
//         "kubernetes.io/role/elb" = 1
//       }
//     }
//     private-2 = {
//       subnet_suffix = "private-2"
//       tgw_route = false
//       intra = true
//       cidrs = [
//         "10.${local.vpc_number}.16.0/24",
//         "10.${local.vpc_number}.17.0/24",
//         "10.${local.vpc_number}.18.0/24"
//       ]
//       additional_routes = [
//         {
//           transit_gateway_id = tgw-1234567
//           destination_cidr_block = 0.0.0.0/0
//         },
//         {
//           network_interface_id = eni-3456789
//           destination_cidr_block = 0.0.0.0/0
//         }
//       ]
//       tags = {
//         "kubernetes.io/role/elb" = 1
//       }
//     }
//   }
//   database_subnets = {
//     db = {
//       subnet_suffix = "db"
//       cidrs = [
//         "10.${local.vpc_number}.20.0/24",
//         "10.${local.vpc_number}.21.0/24",
//         "10.${local.vpc_number}.22.0/24",
//         "10.${local.vpc_number}.23.0/24",
//         "10.${local.vpc_number}.24.0/24",
//         "10.${local.vpc_number}.25.0/24"
//       ]
//       nat_gateway_route = false
//       tags = {
//         "kubernetes.io/role/internal-elb" = 1
//       }
//     }
//     db-2 = {
//       subnet_suffix = "db-2"
//       cidrs = [
//         "10.${local.vpc_number}.26.0/24",
//         "10.${local.vpc_number}.27.0/24",
//         "10.${local.vpc_number}.28.0/24"
//       ]
//       database_subnet_group = false
//       internet_gateway_route = true
//       nat_gateway_route = false
//       tags = {
//         "kubernetes.io/role/internal-elb" = 1
//       }
//     }
//   }

  tags = local.tags
}
