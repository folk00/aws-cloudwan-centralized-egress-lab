provider "aws" {
  region = var.region_iad

  default_tags {
    tags = local.common_tags
  }
}

provider "aws" {
  alias  = "pdx"
  region = var.region_pdx

  default_tags {
    tags = local.common_tags
  }
}

provider "aws" {
  alias  = "dub"
  region = var.region_dub

  default_tags {
    tags = local.common_tags
  }
}

