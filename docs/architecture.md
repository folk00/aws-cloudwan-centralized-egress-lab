# Architecture

## Goal

This lab demonstrates a multi-region AWS Cloud WAN backbone with centralized
egress inspection.

The design focuses on:

- global network backbone across IAD, PDX and DUB
- AWS Cloud WAN
- centralized egress using AWS Network Firewall
- Terraform
- monitoring and troubleshooting

This project maps those requirements into a deployable lab.

## Region Layout

| Code | Region | Workload CIDR | Inspection CIDR |
| --- | --- | --- | --- |
| IAD | `us-east-1` | `10.10.0.0/16` | `100.64.10.0/24` |
| PDX | `us-west-2` | `10.20.0.0/16` | `100.64.20.0/24` |
| DUB | `eu-west-1` | `10.30.0.0/16` | `100.64.30.0/24` |

For a cheaper hands-on run, set:

```hcl
enabled_regions = ["iad", "pdx"]
```

That keeps the Cloud WAN/service-insertion pattern but skips DUB resources.

## Cloud WAN Control Plane

```text
Global Network
  -> Core Network
     -> Core Network Edge: us-east-1
     -> Core Network Edge: us-west-2
     -> Core Network Edge: eu-west-1
        -> Segment: Prod
        -> Segment: Shared
        -> Network Function Group: InspectionNFG
```

VPC attachments are mapped using attachment tags:

```text
segment=Prod
  -> Prod segment

network-function-group=InspectionNFG
  -> InspectionNFG network function group
```

## Data Plane: North-South Egress

For a workload in the IAD workload VPC:

```text
Private EC2 validation host
  -> workload subnet route table
  -> Cloud WAN core network ARN
  -> Prod segment default route
  -> local InspectionNFG attachment
  -> inspection VPC Cloud WAN attachment subnet
  -> AWS Network Firewall endpoint
  -> NAT Gateway
  -> Internet Gateway
  -> Internet
```

The optional validation hosts are private Amazon Linux instances. They have no
public IP and no SSH ingress. Access is through AWS Systems Manager Session
Manager after the instance can reach SSM endpoints through the egress path.

Return traffic follows the reverse path:

```text
Internet
  -> IGW
  -> NAT Gateway
  -> public route table route to firewall endpoint
  -> AWS Network Firewall endpoint
  -> firewall route table route to Cloud WAN
  -> Prod workload attachment
  -> workload subnet
```

## Why Use A Network Function Group

Cloud WAN service insertion uses a Network Function Group to represent regional
security/inspection attachments. This is cleaner than manually inserting static
routes in every segment and every region.

For egress inspection, the policy uses:

```json
{
  "action": "send-to",
  "segment": "Prod",
  "via": {
    "network-function-groups": ["InspectionNFG"]
  }
}
```

Service insertion lets Cloud WAN steer traffic to the inspection VPC using
policy, not hundreds of manually maintained routes.

`Prod` uses `isolate-attachments = true` so workload attachments in the same
segment do not bypass the inspection path.

## Terraform Resource Map

Cloud WAN:

- `aws_networkmanager_global_network`
- `aws_networkmanager_core_network`
- `aws_networkmanager_vpc_attachment`
- `aws_networkmanager_core_network_policy_attachment`

Workload VPC:

- `aws_vpc`
- `aws_subnet`
- `aws_route_table`
- `aws_route`
- `aws_security_group`
- optional `aws_instance` private validation host
- optional IAM role/profile for SSM Session Manager
- optional `aws_flow_log`

Inspection VPC:

- `aws_vpc`
- `aws_subnet`
- `aws_internet_gateway`
- `aws_eip`
- `aws_nat_gateway`
- `aws_networkfirewall_rule_group`
- `aws_networkfirewall_firewall_policy`
- `aws_networkfirewall_firewall`
- `aws_networkfirewall_logging_configuration`
- route tables for Cloud WAN, firewall and public subnets

## Validation Commands

Terraform outputs:

```powershell
terraform output regions
terraform output workload_vpcs
terraform output inspection_vpcs
terraform output test_instances
```

Cloud WAN:

```powershell
aws networkmanager list-core-networks
aws networkmanager get-core-network --core-network-id <core-network-id>
aws networkmanager get-core-network-policy --core-network-id <core-network-id> --alias LIVE
aws networkmanager list-attachments --core-network-id <core-network-id>
```

Network Firewall:

```powershell
aws network-firewall describe-firewall --firewall-name <firewall-name> --region us-east-1
aws network-firewall describe-firewall-policy --firewall-policy-arn <arn> --region us-east-1
aws logs tail /aws/network-firewall/<name>/flow --region us-east-1
```

VPC route checks:

```powershell
aws ec2 describe-route-tables --region us-east-1
aws ec2 describe-route-tables --region us-west-2
aws ec2 describe-route-tables --region eu-west-1
```

Private test host:

```powershell
aws ssm start-session --target <instance-id> --region us-east-1
curl -I https://aws.amazon.com
dig amazon.com
```

## Design Choices

### 1 AZ default

The default lab uses one AZ per region to keep demo cost lower. For production,
use at least two AZs per region.

### Toggle expensive services

The project can create VPCs without Cloud WAN, and Cloud WAN without Network
Firewall. This lets you inspect plans and learn the graph before spending.

### Regional inspection VPCs

The full design creates an inspection VPC in every region. This avoids
unnecessary cross-region egress and matches AWS guidance for keeping egress
traffic local where possible.

## Known Limitations

- No EC2 test instances are deployed by default.
- Test instances require working outbound access to appear in SSM.
- No multi-account AWS Organizations or RAM sharing is included.
- No Direct Connect or Site-to-Site VPN attachments are included yet.
- Firewall rules are deliberately simple. They demonstrate policy attachment,
  not production threat prevention.
- Production needs stricter route review, alerting, dashboards, security rules,
  and change control.
