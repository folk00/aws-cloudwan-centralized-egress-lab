# Cost Estimate

Pricing changes over time. This estimate uses public AWS pricing pages checked
on May 27, 2026 and should be treated as a planning estimate, not a quote.

## Pricing Inputs Used

Cloud WAN:

- Core Network Edge: `USD 0.50/hour`.
- Data processing: `USD 0.02/GB`.
- VPC attachment example: `USD 0.065/hour` in us-east-1.

Network Firewall:

- Firewall endpoint: `USD 0.395/hour`.
- Data processing: `USD 0.065/GB`.

NAT Gateway:

- Standard NAT Gateway example: `USD 0.045/hour` and `USD 0.045/GB`.
- AWS Network Firewall pricing examples indicate NAT Gateway hourly/data
  charges can be discounted when NAT is in the same chained path as Network
  Firewall. This estimate shows both with and without that discount.

Public IPv4:

- Public IPv4 address: `USD 0.005/hour`.

EC2 validation hosts:

- `t3.nano` is used as the default small Linux validation host.
- The estimate uses `USD 0.0052/hour` per `t3.nano` plus about `USD 0.64/month`
  for an 8 GiB gp3 root volume. This is tiny compared with Cloud WAN and
  Network Firewall.

Sources:

- AWS Cloud WAN pricing: https://aws.amazon.com/cloud-wan/pricing/
- AWS Network Firewall pricing: https://aws.amazon.com/network-firewall/pricing/
- Amazon VPC pricing: https://aws.amazon.com/vpc/pricing/
- Amazon EC2 On-Demand pricing: https://aws.amazon.com/ec2/pricing/on-demand/

## Full Lab Assumptions

Full 1-AZ-per-region demo:

- 3 regions: IAD, PDX, DUB.
- 3 Cloud WAN core network edges.
- 6 Cloud WAN VPC attachments:
  - 3 workload VPC attachments.
  - 3 inspection VPC attachments.
- 3 Network Firewall endpoints.
- 3 NAT Gateways.
- 3 public IPv4 addresses for NAT Gateways.
- 3 private `t3.nano` validation instances.
- No meaningful traffic.
- 730 hours/month.

## Monthly Estimate: 1 AZ Per Region

| Component | Formula | Estimate |
| --- | --- | ---: |
| Cloud WAN core network edges | `3 x 0.50 x 730` | `USD 1,095.00` |
| Cloud WAN VPC attachments | `6 x 0.065 x 730` | `USD 284.70` |
| Network Firewall endpoints | `3 x 0.395 x 730` | `USD 865.05` |
| Public IPv4 for NAT | `3 x 0.005 x 730` | `USD 10.95` |
| Private EC2 validation hosts | `3 x 0.0052 x 730` | `USD 11.39` |
| 8 GiB gp3 root volumes | `3 x 0.64` | `USD 1.92` |
| NAT Gateway hourly, if discounted | `0` | `USD 0.00` |
| NAT Gateway hourly, if not discounted | `3 x 0.045 x 730` | `USD 98.55` |

Estimated total with NAT discount:

```text
USD 2,269.01/month
```

Estimated total without NAT discount:

```text
USD 2,367.56/month
```

## Cheap 2-Region Lab

The cheap file `examples/cheap-2region-lab.tfvars.example` deploys only IAD and
PDX:

- 2 Cloud WAN core network edges.
- 4 Cloud WAN VPC attachments.
- 2 Network Firewall endpoints.
- 2 NAT Gateways.
- 2 public IPv4 addresses.
- 2 private `t3.nano` validation instances.

Approximate 2-hour demo:

| Component | Estimate |
| --- | ---: |
| Cloud WAN core network edges | `USD 2.00` |
| Cloud WAN VPC attachments | `USD 0.52` |
| Network Firewall endpoints | `USD 1.58` |
| Public IPv4 for NAT | `USD 0.02` |
| EC2 + tiny root volumes | `~USD 0.02` |
| NAT Gateway hourly, if discounted | `USD 0.00` |
| NAT Gateway hourly, if not discounted | `USD 0.18` |

Estimated 2-hour total:

```text
USD 4.14 with NAT discount
USD 4.32 without NAT discount
```

## Short Demo Windows

Approximate cost if deployed only for a short demo and destroyed immediately:

| Duration | With NAT discount | Without NAT discount |
| --- | ---: | ---: |
| 4 hours | `USD 12.43` | `USD 12.97` |
| 8 hours | `USD 24.87` | `USD 25.95` |
| 24 hours | `USD 74.62` | `USD 77.86` |

## HA Variant: 2 AZ Per Region

For a more production-looking topology:

- Cloud WAN fixed cost stays roughly the same.
- VPC attachment count stays the same.
- Network Firewall endpoints double from 3 to 6.
- NAT Gateway/public IPv4 count doubles from 3 to 6.

Estimated total with NAT discount:

```text
USD 3,131.70/month
```

Estimated total without NAT discount:

```text
USD 3,328.80/month
```

## Cost Command

Run the included helper:

```powershell
cd .
.\scripts\estimate-cost.ps1 -Hours 730 -AzPerRegion 1 -AssumeNatFirewallDiscount
.\scripts\estimate-cost.ps1 -Hours 730 -AzPerRegion 1
.\scripts\estimate-cost.ps1 -Hours 24 -AzPerRegion 1 -AssumeNatFirewallDiscount
.\scripts\estimate-cost.ps1 -Hours 2 -Regions 2 -WorkloadVpcAttachments 2 -InspectionVpcAttachments 2 -TestInstances 2 -AssumeNatFirewallDiscount
```

## Practical Advice

Do not leave the full lab running.

Best workflow:

1. `terraform plan` with defaults.
2. Enable Cloud WAN and inspect plan.
3. Enable Network Firewall only when ready.
4. Apply for a short window.
5. Take screenshots and notes.
6. `terraform destroy`.
