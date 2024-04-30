include "root" {
  path = find_in_parent_folders()
}

include "common" {
  path = "../../../../_common/vpc.hcl"
}

inputs = {
  enable_nat_gateway   = true
}