data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  spoke_routes_by_az = {
    for item in flatten([
      for az_index in range(var.az_count) : [
        for cidr in var.spoke_cidrs : {
          key      = "${az_index}-${replace(replace(cidr, "/", "-"), ".", "-")}"
          az_index = az_index
          cidr     = cidr
        }
      ]
    ]) : item.key => item
  }

  firewall_sync_states = var.enable_network_firewall ? tolist(aws_networkfirewall_firewall.this[0].firewall_status[0].sync_states) : []
  firewall_endpoint_by_az = {
    for state in local.firewall_sync_states : state.availability_zone => state.attachment[0].endpoint_id
    if length(state.attachment) > 0
  }
}

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.name
    Role = "inspection"
  }
}

resource "aws_internet_gateway" "this" {
  count = var.enable_nat_gateway ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-igw"
  }
}

resource "aws_subnet" "cloudwan" {
  count = var.az_count

  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.cidr_block, 4, count.index)
  availability_zone = local.azs[count.index]

  tags = {
    Name = "${var.name}-cloudwan-${count.index + 1}"
    Tier = "cloudwan-attachment"
  }
}

resource "aws_subnet" "firewall" {
  count = var.az_count

  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.cidr_block, 4, count.index + 4)
  availability_zone = local.azs[count.index]

  tags = {
    Name = "${var.name}-firewall-${count.index + 1}"
    Tier = "firewall"
  }
}

resource "aws_subnet" "public" {
  count = var.az_count

  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.cidr_block, 4, count.index + 8)
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name}-public-${count.index + 1}"
    Tier = "public-egress"
  }
}

resource "aws_route_table" "cloudwan" {
  count = var.az_count

  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-cloudwan-rt-${count.index + 1}"
  }
}

resource "aws_route_table" "firewall" {
  count = var.az_count

  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-firewall-rt-${count.index + 1}"
  }
}

resource "aws_route_table" "public" {
  count = var.az_count

  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-public-rt-${count.index + 1}"
  }
}

resource "aws_route_table_association" "cloudwan" {
  count = var.az_count

  subnet_id      = aws_subnet.cloudwan[count.index].id
  route_table_id = aws_route_table.cloudwan[count.index].id
}

resource "aws_route_table_association" "firewall" {
  count = var.az_count

  subnet_id      = aws_subnet.firewall[count.index].id
  route_table_id = aws_route_table.firewall[count.index].id
}

resource "aws_route_table_association" "public" {
  count = var.az_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}

resource "aws_route" "public_default_to_igw" {
  count = var.enable_nat_gateway ? var.az_count : 0

  route_table_id         = aws_route_table.public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? var.az_count : 0

  domain = "vpc"

  tags = {
    Name = "${var.name}-nat-eip-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "this" {
  count = var.enable_nat_gateway ? var.az_count : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.name}-nat-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.this]
}

resource "aws_networkfirewall_rule_group" "stateful_egress" {
  count = var.enable_network_firewall ? 1 : 0

  capacity = 100
  name     = "${var.name}-stateful-egress"
  type     = "STATEFUL"

  rule_group {
    rules_source {
      rules_string = <<-RULES
        pass tcp 10.0.0.0/8 any -> any 443 (msg:"allow https from RFC1918 workloads"; sid:1001; rev:1;)
        pass tcp 10.0.0.0/8 any -> any 80 (msg:"allow http from RFC1918 workloads"; sid:1002; rev:1;)
        pass udp 10.0.0.0/8 any -> any 53 (msg:"allow dns udp from RFC1918 workloads"; sid:1003; rev:1;)
        pass tcp 10.0.0.0/8 any -> any 53 (msg:"allow dns tcp from RFC1918 workloads"; sid:1004; rev:1;)
      RULES
    }
  }

  tags = {
    Name = "${var.name}-stateful-egress"
  }
}

resource "aws_networkfirewall_firewall_policy" "this" {
  count = var.enable_network_firewall ? 1 : 0

  name = "${var.name}-firewall-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.stateful_egress[0].arn
    }
  }

  tags = {
    Name = "${var.name}-firewall-policy"
  }
}

resource "aws_networkfirewall_firewall" "this" {
  count = var.enable_network_firewall ? 1 : 0

  name                = "${var.name}-firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.this[0].arn
  vpc_id              = aws_vpc.this.id

  delete_protection                 = false
  firewall_policy_change_protection = false
  subnet_change_protection          = false

  dynamic "subnet_mapping" {
    for_each = aws_subnet.firewall

    content {
      subnet_id = subnet_mapping.value.id
    }
  }

  tags = {
    Name = "${var.name}-firewall"
  }
}

resource "aws_cloudwatch_log_group" "firewall_flow" {
  count = var.enable_network_firewall ? 1 : 0

  name              = "/aws/network-firewall/${var.name}/flow"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_group" "firewall_alert" {
  count = var.enable_network_firewall ? 1 : 0

  name              = "/aws/network-firewall/${var.name}/alert"
  retention_in_days = var.log_retention_days
}

resource "aws_networkfirewall_logging_configuration" "this" {
  count = var.enable_network_firewall ? 1 : 0

  firewall_arn = aws_networkfirewall_firewall.this[0].arn

  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.firewall_flow[0].name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "FLOW"
    }

    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.firewall_alert[0].name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "ALERT"
    }
  }
}

resource "aws_route" "cloudwan_default_to_firewall" {
  for_each = var.enable_network_firewall ? {
    for idx in range(var.az_count) : tostring(idx) => {
      route_table_id = aws_route_table.cloudwan[idx].id
      endpoint_id    = lookup(local.firewall_endpoint_by_az, aws_subnet.cloudwan[idx].availability_zone, null)
    }
  } : {}

  route_table_id         = each.value.route_table_id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = each.value.endpoint_id

  depends_on = [aws_networkfirewall_firewall.this]
}

resource "aws_route" "firewall_default_to_nat" {
  count = var.enable_network_firewall && var.enable_nat_gateway ? var.az_count : 0

  route_table_id         = aws_route_table.firewall[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[count.index].id
}

resource "aws_route" "public_to_spokes_via_firewall" {
  for_each = var.enable_network_firewall ? local.spoke_routes_by_az : {}

  route_table_id         = aws_route_table.public[each.value.az_index].id
  destination_cidr_block = each.value.cidr
  vpc_endpoint_id        = lookup(local.firewall_endpoint_by_az, aws_subnet.public[each.value.az_index].availability_zone, null)

  depends_on = [aws_networkfirewall_firewall.this]
}

resource "aws_cloudwatch_log_group" "flow_logs" {
  count = var.enable_vpc_flow_logs ? 1 : 0

  name              = "/aws/vpc-flow-logs/${var.name}"
  retention_in_days = var.log_retention_days
}

resource "aws_iam_role" "flow_logs" {
  count = var.enable_vpc_flow_logs ? 1 : 0

  name = "${var.name}-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "flow_logs" {
  count = var.enable_vpc_flow_logs ? 1 : 0

  name = "${var.name}-flow-logs-policy"
  role = aws_iam_role.flow_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_flow_log" "this" {
  count = var.enable_vpc_flow_logs ? 1 : 0

  iam_role_arn    = aws_iam_role.flow_logs[0].arn
  log_destination = aws_cloudwatch_log_group.flow_logs[0].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.this.id
}
