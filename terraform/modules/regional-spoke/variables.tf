variable "name" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "az_count" {
  type = number
}

variable "enable_vpc_flow_logs" {
  type    = bool
  default = false
}

variable "enable_test_instance" {
  type    = bool
  default = false
}

variable "test_instance_type" {
  type    = string
  default = "t3.nano"
}

variable "log_retention_days" {
  type    = number
  default = 7
}
