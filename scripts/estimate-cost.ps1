param(
    [int]$Hours = 730,
    [int]$Regions = 3,
    [int]$AzPerRegion = 1,
    [int]$WorkloadVpcAttachments = 3,
    [int]$InspectionVpcAttachments = 3,
    [int]$TestInstances = 0,
    [double]$CloudWanCneHourly = 0.50,
    [double]$CloudWanAttachmentHourly = 0.065,
    [double]$NetworkFirewallEndpointHourly = 0.395,
    [double]$NatGatewayHourly = 0.045,
    [double]$PublicIpv4Hourly = 0.005,
    [double]$TestInstanceHourly = 0.0052,
    [double]$TestInstanceEbsMonthly = 0.64,
    [switch]$AssumeNatFirewallDiscount
)

$attachments = $WorkloadVpcAttachments + $InspectionVpcAttachments
$cne = $Regions * $CloudWanCneHourly * $Hours
$attachmentCost = $attachments * $CloudWanAttachmentHourly * $Hours
$firewallEndpoints = $Regions * $AzPerRegion
$firewall = $firewallEndpoints * $NetworkFirewallEndpointHourly * $Hours
$nat = if ($AssumeNatFirewallDiscount) { 0 } else { $firewallEndpoints * $NatGatewayHourly * $Hours }
$ipv4 = $firewallEndpoints * $PublicIpv4Hourly * $Hours
$testEc2 = $TestInstances * $TestInstanceHourly * $Hours
$testEbs = $TestInstances * ($TestInstanceEbsMonthly / 730) * $Hours
$total = $cne + $attachmentCost + $firewall + $nat + $ipv4 + $testEc2 + $testEbs

[PSCustomObject]@{
    Hours = $Hours
    Regions = $Regions
    AzPerRegion = $AzPerRegion
    CloudWanCoreNetworkEdges = [math]::Round($cne, 2)
    CloudWanVpcAttachments = [math]::Round($attachmentCost, 2)
    NetworkFirewallEndpoints = [math]::Round($firewall, 2)
    NatGateways = [math]::Round($nat, 2)
    PublicIPv4 = [math]::Round($ipv4, 2)
    TestInstances = [math]::Round($testEc2, 2)
    TestInstanceEbs = [math]::Round($testEbs, 2)
    EstimatedTotalUSD = [math]::Round($total, 2)
}
