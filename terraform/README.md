# Terraform Usage

Default plan, no expensive resources:

```powershell
terraform init
terraform plan
```

Full deployment:

```powershell
Copy-Item ..\examples\full-lab.tfvars.example .\full-lab.auto.tfvars
terraform plan "-out=cloudwan-full.tfplan"
terraform apply cloudwan-full.tfplan
```

Cheap 2-region deployment:

```powershell
Copy-Item ..\examples\cheap-2region-lab.tfvars.example .\cheap-2region.auto.tfvars
terraform plan "-out=cloudwan-cheap.tfplan"
terraform apply cloudwan-cheap.tfplan
```

Expand the existing cheap deployment to 3 regions:

```powershell
terraform plan "-var-file=..\examples\current-3region-lab.tfvars.example" "-out=cloudwan-3region.tfplan"
terraform apply cloudwan-3region.tfplan
```

Destroy:

```powershell
terraform destroy
```

## Important Toggles

```hcl
enable_cloudwan          = true
enable_service_insertion = true
enable_network_firewall  = true
enable_nat_gateway       = true
enable_vpc_flow_logs     = false
enable_test_instances    = true
enabled_regions          = ["iad", "pdx"]
az_count                 = 1
```

`az_count = 1` is the cost-aware demo mode. Use `az_count = 2` if you want to
show a more production-like high availability shape.

`enabled_regions = ["iad", "pdx"]` is the cheapest useful Cloud WAN version.
It still demonstrates multi-region Cloud WAN but avoids the third core network
edge, third inspection VPC and two extra attachments.

## Files

| File | Purpose |
| --- | --- |
| `providers.tf` | AWS providers for IAD, PDX and DUB |
| `locals.tf` | Tags and Cloud WAN policy document |
| `main.tf` | Regional workload and inspection VPC modules |
| `cloudwan.tf` | Global network, core network, VPC attachments and LIVE policy |
| `routes.tf` | Workload default routes to Cloud WAN |
| `modules/regional-spoke` | Workload VPC module |
| `modules/inspection-vpc` | Inspection VPC, Network Firewall, NAT and routing |
