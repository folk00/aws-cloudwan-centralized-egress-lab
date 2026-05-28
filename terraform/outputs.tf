output "regions" {
  value = merge(
    local.enable_iad ? { iad = var.region_iad } : {},
    local.enable_pdx ? { pdx = var.region_pdx } : {},
    local.enable_dub ? { dub = var.region_dub } : {}
  )
}

output "cloudwan" {
  value = var.enable_cloudwan ? {
    global_network_id = aws_networkmanager_global_network.this[0].id
    core_network_id   = aws_networkmanager_core_network.this[0].id
    core_network_arn  = aws_networkmanager_core_network.this[0].arn
    policy_preview    = local.core_network_policy
  } : null
}

output "workload_vpcs" {
  value = merge(
    local.enable_iad ? { iad = module.workload_iad[0].summary } : {},
    local.enable_pdx ? { pdx = module.workload_pdx[0].summary } : {},
    local.enable_dub ? { dub = module.workload_dub[0].summary } : {}
  )
}

output "inspection_vpcs" {
  value = merge(
    local.enable_iad ? { iad = module.inspection_iad[0].summary } : {},
    local.enable_pdx ? { pdx = module.inspection_pdx[0].summary } : {},
    local.enable_dub ? { dub = module.inspection_dub[0].summary } : {}
  )
}

output "test_instances" {
  value = merge(
    local.enable_iad ? { iad = module.workload_iad[0].test_instance } : {},
    local.enable_pdx ? { pdx = module.workload_pdx[0].test_instance } : {},
    local.enable_dub ? { dub = module.workload_dub[0].test_instance } : {}
  )
}

output "interview_validation_commands" {
  value = var.enable_cloudwan ? [
    "aws networkmanager get-core-network --core-network-id ${aws_networkmanager_core_network.this[0].id}",
    "aws networkmanager get-core-network-policy --core-network-id ${aws_networkmanager_core_network.this[0].id} --alias LIVE",
    "aws networkmanager list-attachments --core-network-id ${aws_networkmanager_core_network.this[0].id}",
  ] : []
}
