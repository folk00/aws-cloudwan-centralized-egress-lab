resource "aws_route" "workload_iad_default_to_cloudwan" {
  count = var.enable_cloudwan && local.enable_iad ? 1 : 0

  route_table_id         = module.workload_iad[0].private_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  core_network_arn       = aws_networkmanager_core_network.this[0].arn

  depends_on = [
    aws_networkmanager_vpc_attachment.prod_iad,
    aws_networkmanager_core_network_policy_attachment.live,
  ]
}

resource "aws_route" "workload_pdx_default_to_cloudwan" {
  provider = aws.pdx
  count    = var.enable_cloudwan && local.enable_pdx ? 1 : 0

  route_table_id         = module.workload_pdx[0].private_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  core_network_arn       = aws_networkmanager_core_network.this[0].arn

  depends_on = [
    aws_networkmanager_vpc_attachment.prod_pdx,
    aws_networkmanager_core_network_policy_attachment.live,
  ]
}

resource "aws_route" "workload_dub_default_to_cloudwan" {
  provider = aws.dub
  count    = var.enable_cloudwan && local.enable_dub ? 1 : 0

  route_table_id         = module.workload_dub[0].private_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  core_network_arn       = aws_networkmanager_core_network.this[0].arn

  depends_on = [
    aws_networkmanager_vpc_attachment.prod_dub,
    aws_networkmanager_core_network_policy_attachment.live,
  ]
}

resource "aws_route" "inspection_iad_firewall_to_spokes_via_cloudwan" {
  for_each = var.enable_cloudwan && var.enable_network_firewall && local.enable_iad ? {
    for item in flatten([
      for idx, route_table_id in module.inspection_iad[0].firewall_route_table_ids : [
        for cidr in local.spoke_cidrs : {
          key            = "${idx}-${replace(replace(cidr, "/", "-"), ".", "-")}"
          route_table_id = route_table_id
          cidr           = cidr
        }
      ]
    ]) : item.key => item
  } : {}

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.cidr
  core_network_arn       = aws_networkmanager_core_network.this[0].arn

  depends_on = [
    aws_networkmanager_core_network_policy_attachment.live,
    aws_networkmanager_vpc_attachment.inspection_iad,
    aws_networkmanager_vpc_attachment.prod_iad,
    aws_networkmanager_vpc_attachment.prod_pdx,
    aws_networkmanager_vpc_attachment.prod_dub,
  ]
}

resource "aws_route" "inspection_pdx_firewall_to_spokes_via_cloudwan" {
  provider = aws.pdx

  for_each = var.enable_cloudwan && var.enable_network_firewall && local.enable_pdx ? {
    for item in flatten([
      for idx, route_table_id in module.inspection_pdx[0].firewall_route_table_ids : [
        for cidr in local.spoke_cidrs : {
          key            = "${idx}-${replace(replace(cidr, "/", "-"), ".", "-")}"
          route_table_id = route_table_id
          cidr           = cidr
        }
      ]
    ]) : item.key => item
  } : {}

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.cidr
  core_network_arn       = aws_networkmanager_core_network.this[0].arn

  depends_on = [
    aws_networkmanager_core_network_policy_attachment.live,
    aws_networkmanager_vpc_attachment.inspection_pdx,
    aws_networkmanager_vpc_attachment.prod_iad,
    aws_networkmanager_vpc_attachment.prod_pdx,
    aws_networkmanager_vpc_attachment.prod_dub,
  ]
}

resource "aws_route" "inspection_dub_firewall_to_spokes_via_cloudwan" {
  provider = aws.dub

  for_each = var.enable_cloudwan && var.enable_network_firewall && local.enable_dub ? {
    for item in flatten([
      for idx, route_table_id in module.inspection_dub[0].firewall_route_table_ids : [
        for cidr in local.spoke_cidrs : {
          key            = "${idx}-${replace(replace(cidr, "/", "-"), ".", "-")}"
          route_table_id = route_table_id
          cidr           = cidr
        }
      ]
    ]) : item.key => item
  } : {}

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.cidr
  core_network_arn       = aws_networkmanager_core_network.this[0].arn

  depends_on = [
    aws_networkmanager_core_network_policy_attachment.live,
    aws_networkmanager_vpc_attachment.inspection_dub,
    aws_networkmanager_vpc_attachment.prod_iad,
    aws_networkmanager_vpc_attachment.prod_pdx,
    aws_networkmanager_vpc_attachment.prod_dub,
  ]
}
