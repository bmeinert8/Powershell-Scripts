#LAB 6: IMPLEMENT TRAFFIC MANAGEMENT

# Task 1: Provision the lab enviornment

#create the resourcegroup
$rgName = 'az104-06-rg1'
$location = 'eastus'
New-AzResourceGroup -Name $rgName -Location $location

#deploy lab 6 template files
New-AzResourceGroupDeployment -ResourceGroupName $rgName -TemplateFile $HOME/az104-06-vms-loop-template.json -TemplateParameterFile $HOME/az104-06-vms-loop-parameters.json

# add network watcher extension to the vms
$vmNames = (Get-AzVM-ResourceGroupName $rgName).Name

foreach )$vmName in $vmNames) {
    Set-AzVMExtension `
    -ResourceGroupName $rgName `
    -Location $location `
    -VMName $vmName
    -Name 'networkWatcherAgent' `
    -Publisher 'Microsoft.Azure.NetworkWatcher' `
    -Type 'NetworkWatcherAgentWindows' `
    -TypeHandlerVersion '1.4'
}

#Task 2: Configure the Hub and spoke network topology

$vnet1 = Get-AzVirtualNetwork -Name 'az104-06-vnet01' -ResourceGroupName $rgName
$vnet2 = Get-AzVirtualNetwork -Name 'az104-06-vnet2' -ResourceGroupName $rgName
$vnet3 = Get-AzVirtualNetwork -Name 'az104-06-vnet3' -ResourceGroupName $rgName

#peer vnet1 and vnet 2

Add-AzVirtualNetworkPeering -Name 'az104-06-vnet01_to_az104-06-vnet2' -VirtualNetowrk $vnet1 -RemoteVirtualNetworkID $vnet2.id
Add-AzVirtualNetworkPeering -Name 'az104-06-vnet2_to_az104-06-vnet01' -VirtualNetowrk $vnet2 -RemoteVirtualNetworkID $vnet1.id

#peer vnet 1 and vnet 3

Add-AzVirtualNetowkrPeering -Name 'az104-06-vnet01_to_az104-06-vnet3' -VirtualNetwork $vnet1 -RemoteVirtualNetworkID $vnet3.id
Add-AzVirtualNetowkrPeering -Name 'az104-06-vnet3_to_az104-06-vnet01' -VirtualNetowrk $vnet3 -RemoteVirtualNetworkID $vnet1.id

#Task 3: Test transitivity of virtual network peering

#test vm 0 to vm 2

$sourceVMName = "az104-06-vm0"
$destVMName = "az104-06-vm2"

$vm1 = Get-AzVM -ResourceGroupName $rgName | Where-Object -Property Name -EQ $sourceVMName
$vm2 = Get-AzVM -ResourceGroupName $rgName | Where-Object -Property Name -EQ $destVMName

$networkWatcher = Get-AzNetworkWatcher | Where-Object -Property Location -EQ -Value $VM1.Location

Test-AzNetworkWatcherConnectivity -NetworkWatcher $networkWatcher -SourceId $VM1.Id -DestinationId $VM2.Id -DestinationPort 3389

#test vm 0 to vm 3

$sourceVMName = "az104-06-vm0"
$destVMName = "az104-06-vm3"

$vm1 = Get-AzVM -ResourceGroupName $rgName | Where-Object -Property Name -EQ $sourceVMName
$vm2 = Get-AzVM -ResourceGroupName $rgName | Where-Object -Property Name -EQ $destVMName

$networkWatcher = Get-AzNetworkWatcher | Where-Object -Property Location -EQ -Value $VM1.Location

Test-AzNetworkWatcherConnectivity -NetworkWatcher $networkWatcher -SourceId $VM1.Id -DestinationId $VM2.Id -DestinationPort 3389

#test vm 2 to vm 3

$sourceVMName = "az104-06-vm2"
$destVMName = "az104-06-vm3"

$vm1 = Get-AzVM -ResourceGroupName $rgName | Where-Object -Property Name -EQ $sourceVMName
$vm2 = Get-AzVM -ResourceGroupName $rgName | Where-Object -Property Name -EQ $destVMName

$networkWatcher = Get-AzNetworkWatcher | Where-Object -Property Location -EQ -Value $VM1.Location

Test-AzNetworkWatcherConnectivity -NetworkWatcher $networkWatcher -SourceId $VM1.Id -DestinationId $VM2.Id -DestinationPort 3389

#this should fail if set up properly.

#Task4: Configure routing in the hub and spoke topology
$nic0 = Get-AzNetworkInterface -ResourceGroupName $rgName -Name 'az104-06-nic0'
$nic0.EnableIPForwarding = 1
Set-AzNetworkInterface -NetworkInterface $nic0
Execute: $nic0 #and check for an expected output:
EnableIPForwarding   : True
NetworkSecurityGroup : null

#run in vm 0 oppertations run command
Install-WindowsFeature RemoteAccess -IncludeManagementTools

Install-WindowsFeature -Name Routing -IncludeManagementTools -IncludeAllSubFeature

Install-WindowsFeature -Name "RSAT-RemoteAccess-Powershell"

Install-RemoteAccess -VpnType RoutingOnly

Get-NetAdaptor ! Set-NetIPInterface -Forwarding Enabled


#create a route table
New-AzRouteTable -ResourceGroupName $rgName -Name 'az104-06-rt23' -Location $location

#create a route from vnet 2 to vnet 3
Get-AzRouteTable -ResourceGroupName $rgName -Name "az104-06-rt23" | Add-AzRouteConfig  -Name "az104-06-route-vnet2-to-vnet3" -AddressPrefix 10.63.0.0/20 -NextHopType "VirtualAppliance" -NextHopIpAddress 10.60.0.4 | Set-AzRouteTable

#associate the route table to subnet 0 of vnet 2
$vnet2 = Get-AzVirtualNetwork -ResourceGroupName $rgName -Name 'az104-06-vnet2'

$rt23 = Get-AzRouteTable -ResourceGroupName $rgName -Name 'az104-06-rt23'

Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet2 -Name 'subnet0' -RouteTable $rt23 | Set-AzVirtualNetwork

#create 2nd route table
New-AzRouteTable -ResourceGroupName $rgName -Name 'az104-06-rt32' -Location $location

#create a route from vnet 3 to vnet 2
Get-AzRouteTable -ResourceGroupName $rgName -Name "az104-06-rt32" | Add-AzRouteConfig  -Name "az104-06-route-vnet3-to-vnet2" -AddressPrefix 10.62.0.0/20 -NextHopType "VirtualAppliance" -NextHopIpAddress 10.60.0.4 | Set-AzRouteTable

#associate the route table to subnet 0 of vnet 3
$vnet3 = Get-AzVirtualNetwork -ResourceGroupName $rgName -Name 'az104-06-vnet3'

$rt32 = Get-AzRouteTable -ResourceGroupName $rgName -Name 'az104-06-rt32'

Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet3 -Name 'subnet0' -RouteTable $rt32 | Set-AzVirtualNetwork

#test configuration on network watcher
$sourceVMName = "az104-06-vm2"
$destVMName = "az104-06-vm3"

$vm1 = Get-AzVM -ResourceGroupName $rgName | Where-Object -Property Name -EQ $sourceVMName
$vm2 = Get-AzVM -ResourceGroupName $rgName | Where-Object -Property Name -EQ $destVMName

$networkWatcher = Get-AzNetworkWatcher | Where-Object -Property Location -EQ -Value $VM1.Location

Test-AzNetworkWatcherConnectivity -NetworkWatcher $networkWatcher -SourceId $VM1.Id -DestinationId $VM2.Id -DestinationPort 3389

#should pass this time

#Task 5: Implemetn Azure Load Balancer

#create the public frontend ip
$pip = New-AzPublicIpAddress -Name 'az104-06-pip4' -ResourceGroupName $rgName -Location $location -Sku 'Standard' -AllocationMethod 'static'

#create the frontend load balancer
$fip = New-AzLoadBalancerFrontendIpConfig -Name 'az104-06-fe4' -PublicIpAddressId $pip

#create teh backend configuration
$bep = New-AzLoadBalancerBackendAddressPoolConfig -Name 'az104-06-lb4-be1'

#create a probe configuration 
$probe = New-AzLoadBalancerProbeConfig -Name 'az104-06-lb4-hp1' -Protocol 'TCP' -Port 80 -IntervalInSeconds 5 -ProbeCount 2

#loadbalancer rule configuration
$lbrule = New-AzLoadBalancerRuleConfig -Name 'az104-06-lb-rule1' -Protocol 'TCP' -FrontendPort 80 -FrontendIpConfiguration $fip -BackendPort 80 -BackendAddressPool $bep -Probe $probe -IdleTimeoutInMinutes 4

#create the load balancer
New-AzLoadBalancer -Name 'az104-06-lb4' -ResourceGroupName $rgName -Location $location -FrontendIpConfiguration $fip -BackendAddressPool $bep -LoadBalancingRule $lbrule -Probe $probe

#Task 6: Implement Azure Application Gateway

#create the application gateway subnet
$agwsubnet = Add-AzVirtualNetworkSubnetConfig -Name 'subnet-appgw' -AddressPrefix 10.60.3.224/27 -VirtualNetwork $vnet1
$vnet1 | Set-AzVirtualNetwork

#create a new resource group
$rg2 = New-AzResourceGroup -Name 'az104-06-rg5' -Location $location

#create a new public IP address
$pip2 = New-AzPublicIpAddress -Name 'az104-06-pip5' -ResourceGroupName $rg2 -Location $location -Sku 'Standard' -AllocationMethod 'static'

#create application gateway frontend port and ip configurations
$gip = New-AzApplicationGatewayIPConfiguration -Name 'myAGIPConfig' -Subnet $agwsubnet
$fipconfig = New-AzApplicationGatewayFrontendIPConfig -Name 'myAGFrontendIPConfig' -PublicIPAddress $pip2
$frontendport = New-AzApplicationGatewayFrontendPort -Name myFrontendPort -Port 80 

#create the backendpool
$backendPool = New-AzApplicationGatewayBackendAddressPool -Name 'myAGBackendPool' -BackendIPAdresses 10.62.0.4, 10.63.0.4
$poolSettings = New-AzApplicationGatewayBackendHttpSetting -Name 'myPoolSettings'  -Port 80 -Protocol 'Http' -CookieBasedAffinity Enabled -RequestTimeout 30

#create the listener and rule
$defaultlistener = New-AzApplicationGatewayHttpListener -Name myAGListener -Protocol Http -FrontendIPConfiguration $fipconfig -FrontendPort $frontendport
$frontendRule = New-AzApplicationGatewayRequestRoutingRule -Name 'az104-06-appgw5-rl1' -RuleType Basic -Priority 10 -HttpListener $defaultlistener -BackendAddressPool $backendPool -BackendHttpSettings $poolSettings

#create the app gateway
$sku = New-AzApplicationGatewaySku -Name 'Standard_v2' -Tier 'Standard_v2' -Capacity 2
New-AzApplicationGateway -Name myAppGateway -ResourceGroupName $rg2 -Location $location -BackendAddressPools $backendPool -BackendHttpSettingsCollection $poolSettings -FrontendIpConfigurations $fipconfig -GatewayIpConfigurations $gipconfig -FrontendPorts $frontendport -HttpListeners $defaultlistener -RequestRoutingRules $frontendRule -Sku $sku