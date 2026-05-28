variable "project_name" {
  description = "Project prefix used in resource names."
  type        = string
  default     = "cloudwan-egress-lab"
}

variable "environment" {
  description = "Environment label."
  type        = string
  default     = "demo"
}

variable "enabled_regions" {
  description = "Region codes to deploy. Valid values: iad, pdx, dub. Use [\"iad\", \"pdx\"] for a cheaper 2-region demo."
  type        = list(string)
  default     = ["iad", "pdx", "dub"]

  validation {
    condition = length(var.enabled_regions) > 0 && alltrue([
      for region in var.enabled_regions : contains(["iad", "pdx", "dub"], lower(region))
    ])
    error_message = "enabled_regions must contain only iad, pdx and/or dub."
  }
}

variable "region_iad" {
  description = "IAD region."
  type        = string
  default     = "us-east-1"
}

variable "region_pdx" {
  description = "PDX region."
  type        = string
  default     = "us-west-2"
}

variable "region_dub" {
  description = "DUB region."
  type        = string
  default     = "eu-west-1"
}

variable "enable_cloudwan" {
  description = "Create AWS Cloud WAN global/core network and VPC attachments."
  type        = bool
  default     = false
}

variable "enable_service_insertion" {
  description = "Add Cloud WAN send-to service insertion through InspectionNFG."
  type        = bool
  default     = true
}

variable "enable_network_firewall" {
  description = "Create AWS Network Firewall in each inspection VPC."
  type        = bool
  default     = false
}

variable "enable_nat_gateway" {
  description = "Create NAT Gateway in each inspection VPC public subnet."
  type        = bool
  default     = false
}

variable "enable_vpc_flow_logs" {
  description = "Enable VPC Flow Logs to CloudWatch for each VPC."
  type        = bool
  default     = false
}

variable "enable_test_instances" {
  description = "Create one private Amazon Linux test instance per enabled workload VPC with SSM access."
  type        = bool
  default     = false
}

variable "test_instance_type" {
  description = "EC2 instance type for private validation hosts."
  type        = string
  default     = "t3.nano"
}

variable "log_retention_days" {
  description = "CloudWatch log retention for firewall and flow logs."
  type        = number
  default     = 7
}

variable "az_count" {
  description = "Number of AZs per region. Use 1 for cost-aware demo, 2+ for HA story."
  type        = number
  default     = 1

  validation {
    condition     = var.az_count >= 1 && var.az_count <= 3
    error_message = "az_count must be between 1 and 3."
  }
}

variable "workload_iad_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "workload_pdx_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "workload_dub_cidr" {
  type    = string
  default = "10.30.0.0/16"
}

variable "inspection_iad_cidr" {
  type    = string
  default = "100.64.10.0/24"
}

variable "inspection_pdx_cidr" {
  type    = string
  default = "100.64.20.0/24"
}

variable "inspection_dub_cidr" {
  type    = string
  default = "100.64.30.0/24"
}
