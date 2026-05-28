# Cloud WAN Screenshot Checklist

This checklist separates the screenshots already captured from the optional
screenshots that would make the manual console workflow clearer.

## Current Critical Screenshots

These are already organized in `docs/images/cloudwan/`.

| File | Purpose |
| --- | --- |
| `01-global-network-overview-3-edges.png` | Shows the Cloud WAN global network with 3 edge locations and 0 Transit Gateways. |
| `02-cloudwan-attachment-policies.png` | Shows tag-based attachment classification rules. |
| `03-network-function-group-inspectionnfg.png` | Shows the `InspectionNFG` network function group. |
| `04-segment-action-prod-send-to-inspectionnfg.png` | Shows `Prod` traffic being sent to `InspectionNFG`. |
| `05-attachments-segment-and-nfg-mapping.png` | Shows attachment mapping into `Prod` and `InspectionNFG`. |
| `06-workload-vpc-attachment-dub-private-subnet.png` | Shows DUB workload attachment with appliance mode off. |
| `07-inspection-vpc-attachment-appliance-mode.png` | Shows inspection attachment with appliance mode on. |
| `08-prod-segment-three-edge-locations.png` | Shows the `Prod` segment across all edge locations. |
| `09-dub-route-tables-overview.png` | Shows DUB route tables created by the lab. |
| `10-dub-workload-private-rt-default-to-cloudwan.png` | Shows workload default route to Cloud WAN. |
| `11-dub-inspection-cloudwan-rt-default-to-firewall-endpoint.png` | Shows Cloud WAN attachment subnet default route to firewall endpoint. |
| `12-dub-inspection-firewall-rt-nat-and-cloudwan-return.png` | Shows firewall subnet route to NAT and return routes to Cloud WAN. |
| `13-dub-inspection-public-rt-igw-and-firewall-return.png` | Shows public route table, IGW path and firewall return routes. |
| `14-network-firewall-stateful-egress-rules.png` | Shows Suricata-compatible stateful egress rules. |
| `15-network-firewall-ready-in-sync.png` | Shows the DUB firewall ready and in sync. |
| `16-nat-gateway-available.png` | Shows NAT Gateway in available state. |
| `17-private-ec2-instance-dub-no-public-ip.png` | Shows private EC2 validation instance. |
| `18-ssm-run-command-http-200-validation.png` | Shows SSM `HTTP/2 200` validation. |
| `19-cloudwatch-flow-log-tls-443-validation.png` | Shows firewall flow log validation for TCP/443. |
| `20-resource-tags-governance.png` | Shows common governance/cost tags. |

## Optional Screenshots Still Worth Capturing

These are not required for the Terraform lab documentation, but they would help if
the goal is to learn or document how to create the same design manually in the
AWS console.

1. **Create Global Network wizard**
   - Network Manager -> Global networks -> Create global network.
   - Capture the name/description screen.

2. **Create Core Network wizard**
   - Capture the core network creation screen where edge locations are selected.
   - Important because Cloud WAN attachments cannot be created in a region until
     the core network policy has that edge location available.

3. **Policy version LIVE view**
   - Capture the policy version after it is live, not the draft/create screen.
   - Useful to prove that `us-east-1`, `us-west-2` and `eu-west-1` are active.

4. **Create VPC attachment wizard for workload VPC**
   - Show core network, VPC, subnet selection and appliance mode off.
   - Show tags such as `segment = Prod`.

5. **Create VPC attachment wizard for inspection VPC**
   - Show core network, VPC, Cloud WAN subnet selection and appliance mode on.
   - Show tags such as `network-function-group = InspectionNFG`.

6. **Network Firewall create wizard: VPC and subnet selection**
   - The current screenshot shows the firewall policy step.
   - Add the earlier step where the inspection VPC and firewall subnet are chosen.

7. **Firewall policy association**
   - Capture the final policy association after the firewall exists.
   - This is cleaner than only showing the create wizard.

8. **Network Firewall logging configuration**
   - Show flow logs configured to:
     `/aws/network-firewall/cloudwan-egress-lab-cheap-dub-inspection/flow`.
   - This explains why CloudWatch Logs Insights has firewall traffic.

9. **Internet Gateway attached to inspection VPC**
   - Optional, but helps complete the NAT/IGW egress path visually.

10. **Terraform apply output or outputs**
    - Optional. A screenshot of `terraform output` can show VPC IDs, instance IDs
      and core network IDs in one place.

11. **Destroy command confirmation**
    - Optional. Useful for a cost-aware lab guide, but do not run destroy until
      all screenshots and demos are complete.

## Recommended GitHub Gallery Size

For GitHub, do not show every screenshot in the README. Keep the gallery to
6-8 images:

1. Global network overview.
2. Attachment policies.
3. Attachments mapping.
4. DUB route table default to Cloud WAN.
5. Firewall route table or public route table.
6. Network Firewall rules/status.
7. SSM `HTTP/2 200` validation.
8. CloudWatch TCP/443 flow log validation.

Put the rest in `docs/images/cloudwan/` for the full PDF/manual.

## Documents Now Generated

| Document | Status | Notes |
| --- | --- | --- |
| `cloudwan-step-by-step-manual.pdf` | Current | Main illustrated lab guide. |
| `cloudwan-terraform-walkthrough.pdf` | Current | Terraform-focused walkthrough with 27 unique screenshots. |
| `github-screenshot-gallery.md` | Current | Compact GitHub evidence gallery and full screenshot index. |

## Terraform Walkthrough Appendix Screenshots Added

These are organized under `docs/images/cloudwan/terraform-walkthrough/` and
are used only once in `cloudwan-terraform-walkthrough.pdf`.

| File | Purpose |
| --- | --- |
| `22-policy-version-attachment-routing-policies.png` | Cloud WAN policy version details. |
| `23-segment-actions-empty-before-service-insertion.png` | Segment action area during policy inspection. |
| `24-network-firewall-rule-group-tags.png` | Network Firewall rule group tags. |
| `25-network-firewall-stateless-default-actions.png` | Stateless default action forwarding to stateful inspection. |
| `26-network-firewall-details-ready-sync.png` | Detailed Network Firewall ready/in-sync state. |
| `27-ssm-run-command-first-output.png` | Earlier SSM Run Command output during validation. |
| `28-core-network-edge-locations-live.png` | Live Core Network edge location list. |
