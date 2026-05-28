module "workload_iad" {
  count  = local.enable_iad ? 1 : 0
  source = "./modules/regional-spoke"

  providers = {
    aws = aws
  }

  name                 = "${local.name_prefix}-iad-workload"
  cidr_block           = var.workload_iad_cidr
  az_count             = var.az_count
  enable_vpc_flow_logs = var.enable_vpc_flow_logs
  enable_test_instance = var.enable_test_instances
  test_instance_type   = var.test_instance_type
  log_retention_days   = var.log_retention_days
}

module "workload_pdx" {
  count  = local.enable_pdx ? 1 : 0
  source = "./modules/regional-spoke"

  providers = {
    aws = aws.pdx
  }

  name                 = "${local.name_prefix}-pdx-workload"
  cidr_block           = var.workload_pdx_cidr
  az_count             = var.az_count
  enable_vpc_flow_logs = var.enable_vpc_flow_logs
  enable_test_instance = var.enable_test_instances
  test_instance_type   = var.test_instance_type
  log_retention_days   = var.log_retention_days
}

module "workload_dub" {
  count  = local.enable_dub ? 1 : 0
  source = "./modules/regional-spoke"

  providers = {
    aws = aws.dub
  }

  name                 = "${local.name_prefix}-dub-workload"
  cidr_block           = var.workload_dub_cidr
  az_count             = var.az_count
  enable_vpc_flow_logs = var.enable_vpc_flow_logs
  enable_test_instance = var.enable_test_instances
  test_instance_type   = var.test_instance_type
  log_retention_days   = var.log_retention_days
}

module "inspection_iad" {
  count  = local.enable_iad ? 1 : 0
  source = "./modules/inspection-vpc"

  providers = {
    aws = aws
  }

  name                    = "${local.name_prefix}-iad-inspection"
  cidr_block              = var.inspection_iad_cidr
  az_count                = var.az_count
  enable_network_firewall = var.enable_network_firewall
  enable_nat_gateway      = var.enable_nat_gateway
  enable_vpc_flow_logs    = var.enable_vpc_flow_logs
  log_retention_days      = var.log_retention_days
  enable_cloudwan_routes  = var.enable_cloudwan && var.enable_network_firewall
  core_network_arn        = var.enable_cloudwan ? aws_networkmanager_core_network.this[0].arn : null
  spoke_cidrs             = local.spoke_cidrs
}

module "inspection_pdx" {
  count  = local.enable_pdx ? 1 : 0
  source = "./modules/inspection-vpc"

  providers = {
    aws = aws.pdx
  }

  name                    = "${local.name_prefix}-pdx-inspection"
  cidr_block              = var.inspection_pdx_cidr
  az_count                = var.az_count
  enable_network_firewall = var.enable_network_firewall
  enable_nat_gateway      = var.enable_nat_gateway
  enable_vpc_flow_logs    = var.enable_vpc_flow_logs
  log_retention_days      = var.log_retention_days
  enable_cloudwan_routes  = var.enable_cloudwan && var.enable_network_firewall
  core_network_arn        = var.enable_cloudwan ? aws_networkmanager_core_network.this[0].arn : null
  spoke_cidrs             = local.spoke_cidrs
}

module "inspection_dub" {
  count  = local.enable_dub ? 1 : 0
  source = "./modules/inspection-vpc"

  providers = {
    aws = aws.dub
  }

  name                    = "${local.name_prefix}-dub-inspection"
  cidr_block              = var.inspection_dub_cidr
  az_count                = var.az_count
  enable_network_firewall = var.enable_network_firewall
  enable_nat_gateway      = var.enable_nat_gateway
  enable_vpc_flow_logs    = var.enable_vpc_flow_logs
  log_retention_days      = var.log_retention_days
  enable_cloudwan_routes  = var.enable_cloudwan && var.enable_network_firewall
  core_network_arn        = var.enable_cloudwan ? aws_networkmanager_core_network.this[0].arn : null
  spoke_cidrs             = local.spoke_cidrs
}
