resource "aws_networkmanager_global_network" "this" {
  count = var.enable_cloudwan ? 1 : 0

  description = "${local.name_prefix} global network"

  tags = {
    Name = "${local.name_prefix}-global-network"
  }
}

resource "aws_networkmanager_core_network" "this" {
  count = var.enable_cloudwan ? 1 : 0

  global_network_id   = aws_networkmanager_global_network.this[0].id
  description         = "${local.name_prefix} Cloud WAN core network"
  create_base_policy  = true
  base_policy_regions = local.edge_locations

  tags = {
    Name = "${local.name_prefix}-core-network"
  }
}

resource "aws_networkmanager_vpc_attachment" "prod_iad" {
  count = var.enable_cloudwan && local.enable_iad ? 1 : 0

  core_network_id = aws_networkmanager_core_network.this[0].id
  vpc_arn         = module.workload_iad[0].vpc_arn
  subnet_arns     = module.workload_iad[0].private_subnet_arns

  options {
    appliance_mode_support             = false
    dns_support                        = true
    ipv6_support                       = false
    security_group_referencing_support = false
  }

  tags = {
    Name        = "${local.name_prefix}-iad-prod-attachment"
    environment = "Prod"
    segment     = "Prod"
    region_code = "IAD"
  }

  depends_on = [
    aws_networkmanager_core_network_policy_attachment.live,
  ]
}

resource "aws_networkmanager_vpc_attachment" "prod_pdx" {
  count = var.enable_cloudwan && local.enable_pdx ? 1 : 0

  core_network_id = aws_networkmanager_core_network.this[0].id
  vpc_arn         = module.workload_pdx[0].vpc_arn
  subnet_arns     = module.workload_pdx[0].private_subnet_arns

  options {
    appliance_mode_support             = false
    dns_support                        = true
    ipv6_support                       = false
    security_group_referencing_support = false
  }

  tags = {
    Name        = "${local.name_prefix}-pdx-prod-attachment"
    environment = "Prod"
    segment     = "Prod"
    region_code = "PDX"
  }

  depends_on = [
    aws_networkmanager_core_network_policy_attachment.live,
  ]
}

resource "aws_networkmanager_vpc_attachment" "prod_dub" {
  count = var.enable_cloudwan && local.enable_dub ? 1 : 0

  core_network_id = aws_networkmanager_core_network.this[0].id
  vpc_arn         = module.workload_dub[0].vpc_arn
  subnet_arns     = module.workload_dub[0].private_subnet_arns

  options {
    appliance_mode_support             = false
    dns_support                        = true
    ipv6_support                       = false
    security_group_referencing_support = false
  }

  tags = {
    Name        = "${local.name_prefix}-dub-prod-attachment"
    environment = "Prod"
    segment     = "Prod"
    region_code = "DUB"
  }

  depends_on = [
    aws_networkmanager_core_network_policy_attachment.live,
  ]
}

resource "aws_networkmanager_vpc_attachment" "inspection_iad" {
  count = var.enable_cloudwan && var.enable_service_insertion && local.enable_iad ? 1 : 0

  core_network_id = aws_networkmanager_core_network.this[0].id
  vpc_arn         = module.inspection_iad[0].vpc_arn
  subnet_arns     = module.inspection_iad[0].cloudwan_subnet_arns

  options {
    appliance_mode_support             = true
    dns_support                        = true
    ipv6_support                       = false
    security_group_referencing_support = false
  }

  tags = {
    Name                   = "${local.name_prefix}-iad-inspection-attachment"
    environment            = "InspectionNFG"
    network-function-group = "InspectionNFG"
    region_code            = "IAD"
  }

  depends_on = [
    aws_networkmanager_core_network_policy_attachment.live,
  ]
}

resource "aws_networkmanager_vpc_attachment" "inspection_pdx" {
  count = var.enable_cloudwan && var.enable_service_insertion && local.enable_pdx ? 1 : 0

  core_network_id = aws_networkmanager_core_network.this[0].id
  vpc_arn         = module.inspection_pdx[0].vpc_arn
  subnet_arns     = module.inspection_pdx[0].cloudwan_subnet_arns

  options {
    appliance_mode_support             = true
    dns_support                        = true
    ipv6_support                       = false
    security_group_referencing_support = false
  }

  tags = {
    Name                   = "${local.name_prefix}-pdx-inspection-attachment"
    environment            = "InspectionNFG"
    network-function-group = "InspectionNFG"
    region_code            = "PDX"
  }

  depends_on = [
    aws_networkmanager_core_network_policy_attachment.live,
  ]
}

resource "aws_networkmanager_vpc_attachment" "inspection_dub" {
  count = var.enable_cloudwan && var.enable_service_insertion && local.enable_dub ? 1 : 0

  core_network_id = aws_networkmanager_core_network.this[0].id
  vpc_arn         = module.inspection_dub[0].vpc_arn
  subnet_arns     = module.inspection_dub[0].cloudwan_subnet_arns

  options {
    appliance_mode_support             = true
    dns_support                        = true
    ipv6_support                       = false
    security_group_referencing_support = false
  }

  tags = {
    Name                   = "${local.name_prefix}-dub-inspection-attachment"
    environment            = "InspectionNFG"
    network-function-group = "InspectionNFG"
    region_code            = "DUB"
  }

  depends_on = [
    aws_networkmanager_core_network_policy_attachment.live,
  ]
}

resource "aws_networkmanager_core_network_policy_attachment" "live" {
  count = var.enable_cloudwan ? 1 : 0

  core_network_id = aws_networkmanager_core_network.this[0].id
  policy_document = jsonencode(local.core_network_policy)
}
