# Cloud WAN Policy Notes

The lab uses Cloud WAN policy to show the difference between route plumbing and
intent-based WAN design.

## Segments

`Prod` represents workload VPCs.

`Shared` is included as a placeholder for future shared-services VPCs such as
DNS, identity, observability or tooling.

## Network Function Group

`InspectionNFG` represents the regional inspection VPC attachments.

Instead of making the inspection VPC another regular segment, the policy marks
it as a network function group so Cloud WAN can steer selected traffic through
it.

## Attachment Mapping

The policy maps attachments by tags:

```text
segment=Prod
  -> Prod segment

network-function-group=InspectionNFG
  -> InspectionNFG network function group
```

That is the key automation pattern: onboarding a new VPC can be driven by tags
instead of hand-editing route tables one by one.

## Service Insertion

When `enable_service_insertion = true`, the policy adds a `send-to` action for
the `Prod` segment through `InspectionNFG`.

The inspection attachment policy intentionally uses a `tag-exists` condition on
`network-function-group`. Cloud WAN service insertion expects Network Function
Group attachment policies to use that style of tag existence matching.

The `Prod` segment is isolated so same-segment workload attachments cannot route
around the inserted inspection path.

In demos language:

> Workload VPCs are attached to the Prod segment. Egress traffic can be steered
> to the regional inspection VPC through a network function group, then sent
> through AWS Network Firewall and NAT before leaving to the internet.

## Production Questions To Expect

- How would you make this multi-account?
- How do you separate prod, non-prod and shared services?
- How do you prevent a wrong tag from attaching a VPC to the wrong segment?
- How would you validate route propagation before approving a change?
- How do you monitor firewall drops and asymmetric routing?
- How would you support Direct Connect or Site-to-Site VPN attachments later?

Good answer:

> I would add guardrails around attachment tags, separate policy promotion from
> application deployment, use CI checks for Cloud WAN policy JSON, and require
> validation of attachment state, segment membership, route tables and firewall
> logs before declaring the change healthy.
