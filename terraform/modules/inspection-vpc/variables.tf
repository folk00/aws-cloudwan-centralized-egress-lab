variable "name" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "az_count" {
  type = number
}

variable "enable_network_firewall" {
  type    = bool
  default = false
}

variable "enable_nat_gateway" {
  type    = bool
  default = false
}

variable "enable_vpc_flow_logs" {
  type    = bool
  default = false
}

variable "enable_cloudwan_routes" {
  type    = bool
  default = false
}

variable "core_network_arn" {
  type     = string
  default  = null
  nullable = true
}

variable "spoke_cidrs" {
  type    = list(string)
  default = []
}

variable "log_retention_days" {
  type    = number
  default = 7
}

