# Deployment Runbook

This runbook is intentionally simple: validate first, deploy only during a demo
window, and destroy immediately after testing.

## 1. Validate Locally

```powershell
cd .
.\scripts\validate.ps1
```

Expected result:

```text
Success! The configuration is valid.
```

## 2. Review Cost

Full 3-region, 1-AZ demo estimate:

```powershell
.\scripts\estimate-cost.ps1 -Hours 730 -TestInstances 3 -AssumeNatFirewallDiscount
.\scripts\estimate-cost.ps1 -Hours 730 -TestInstances 3
```

Short demo estimate:

```powershell
.\scripts\estimate-cost.ps1 -Hours 8 -TestInstances 3 -AssumeNatFirewallDiscount
.\scripts\estimate-cost.ps1 -Hours 24 -TestInstances 3 -AssumeNatFirewallDiscount
.\scripts\estimate-cost.ps1 -Hours 2 -Regions 2 -WorkloadVpcAttachments 2 -InspectionVpcAttachments 2 -TestInstances 2 -AssumeNatFirewallDiscount
```

## 3. Prepare Variables

```powershell
cd .\terraform
Copy-Item ..\examples\full-lab.tfvars.example .\full-lab.auto.tfvars
```

For the cheaper 2-region version:

```powershell
cd .\terraform
Copy-Item ..\examples\cheap-2region-lab.tfvars.example .\cheap-2region.auto.tfvars
```

The example enables:

```hcl
enable_cloudwan         = true
enable_network_firewall = true
enable_nat_gateway      = true
enable_vpc_flow_logs    = false
enable_test_instances   = true
az_count                = 1
```

## 4. Plan

```powershell
terraform init
terraform plan "-out=cloudwan-full.tfplan"
```

Before applying, check for these resource families:

- `aws_networkmanager_global_network`
- `aws_networkmanager_core_network`
- `aws_networkmanager_vpc_attachment`
- `aws_networkfirewall_firewall`
- `aws_nat_gateway`
- `aws_route`

## 5. Apply

```powershell
terraform apply cloudwan-full.tfplan
```

## 6. Validate AWS Control Plane

Cloud WAN:

```powershell
aws networkmanager list-core-networks
aws networkmanager list-attachments --core-network-id <core-network-id>
aws networkmanager get-core-network-policy --core-network-id <core-network-id> --alias LIVE
```

Network Firewall:

```powershell
aws network-firewall describe-firewall --firewall-name <firewall-name> --region us-east-1
aws network-firewall describe-firewall --firewall-name <firewall-name> --region us-west-2
aws network-firewall describe-firewall --firewall-name <firewall-name> --region eu-west-1
```

Routes:

```powershell
aws ec2 describe-route-tables --region us-east-1
aws ec2 describe-route-tables --region us-west-2
aws ec2 describe-route-tables --region eu-west-1
```

Private validation hosts:

```powershell
terraform output test_instances
aws ssm start-session --target <instance-id> --region us-east-1
curl -I https://aws.amazon.com
dig amazon.com
```

## 7. Destroy

Destroy as soon as the demo is finished:

```powershell
terraform destroy
```

If a destroy gets stuck, check Cloud WAN attachments and Network Firewall
endpoints first. Those are the resources most likely to hold dependencies.
