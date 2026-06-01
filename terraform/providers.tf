# Two providers, one per region. `aws` (default) is the primary in Bangkok;
# `aws.sg` is the DR region in Singapore. Per-region root files (*-th.tf /
# *-sg.tf) pass the matching provider to each module instance.
provider "aws" {
  region = var.th_region
  default_tags {
    tags = local.common_tags
  }
}

provider "aws" {
  alias  = "sg"
  region = var.sg_region
  default_tags {
    tags = local.common_tags
  }
}
