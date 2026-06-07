locals {
  name_prefix = "${var.project_name}-${var.environment}"

  enabled_region_codes = toset([for region in var.enabled_regions : lower(region)])
  enable_iad           = contains(local.enabled_region_codes, "iad")
  enable_pdx           = contains(local.enabled_region_codes, "pdx")
  enable_dub           = contains(local.enabled_region_codes, "dub")

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = "lab-owner"
    Purpose     = "cloudwan-centralized-egress-lab"
  }

  edge_locations = compact([
    local.enable_iad ? var.region_iad : "",
    local.enable_pdx ? var.region_pdx : "",
    local.enable_dub ? var.region_dub : "",
  ])

  spoke_cidrs = compact([
    local.enable_iad ? var.workload_iad_cidr : "",
    local.enable_pdx ? var.workload_pdx_cidr : "",
    local.enable_dub ? var.workload_dub_cidr : "",
  ])

  service_insertion_actions = var.enable_service_insertion ? [
    {
      action  = "send-to"
      segment = "Prod"
      via = {
        "network-function-groups" = ["InspectionNFG"]
      }
    }
  ] : []

  network_function_groups = var.enable_service_insertion ? [
    {
      name                            = "InspectionNFG"
      description                     = "Regional inspection and centralized egress VPC attachments"
      "require-attachment-acceptance" = false
    }
  ] : []

  inspection_attachment_policies = var.enable_service_insertion ? [
    {
      "rule-number"     = 100
      description       = "Map inspection attachments into the network function group"
      "condition-logic" = "and"
      conditions = [
        {
          type = "tag-exists"
          key  = "network-function-group"
        }
      ]
      action = {
        "add-to-network-function-group" = "InspectionNFG"
      }
    }
  ] : []

  segment_attachment_policies = [
    {
      "rule-number"     = 200
      description       = "Map workload attachments to Prod segment"
      "condition-logic" = "or"
      conditions = [
        {
          type     = "tag-value"
          key      = "segment"
          operator = "equals"
          value    = "Prod"
        }
      ]
      action = {
        "association-method" = "constant"
        segment              = "Prod"
      }
    },
    {
      "rule-number"     = 300
      description       = "Map shared attachments to Shared segment"
      "condition-logic" = "or"
      conditions = [
        {
          type     = "tag-value"
          key      = "segment"
          operator = "equals"
          value    = "Shared"
        }
      ]
      action = {
        "association-method" = "constant"
        segment              = "Shared"
      }
    }
  ]

  core_network_policy = {
    version = "2021.12"
    "core-network-configuration" = {
      "vpn-ecmp-support"                   = true
      "dns-support"                        = true
      "security-group-referencing-support" = false
      "asn-ranges"                         = ["64512-65534"]
      "edge-locations" = [
        for region in local.edge_locations : {
          location = region
        }
      ]
    }
    segments = [
      {
        name                            = "Prod"
        description                     = "Production workload segment"
        "edge-locations"                = local.edge_locations
        "isolate-attachments"           = true
        "require-attachment-acceptance" = false
      },
      {
        name                            = "Shared"
        description                     = "Shared services segment placeholder"
        "edge-locations"                = local.edge_locations
        "isolate-attachments"           = false
        "require-attachment-acceptance" = false
      }
    ]
    "network-function-groups" = local.network_function_groups
    "segment-actions"         = local.service_insertion_actions
    "attachment-policies"     = concat(local.inspection_attachment_policies, local.segment_attachment_policies)
  }
}
