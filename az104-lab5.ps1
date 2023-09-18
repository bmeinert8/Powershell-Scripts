#LAB05 IMPLEMENT INTERSITE CONNECTIVITY

#Task 1: Provision the lab Enviornment

#set up resource group
$location1 = 'eastus'
$location2 = 'westus'
$rgName = 'az104-05-rg1'
New-AzResourceGroup -Name $rgName -location $location1

#deploy the lab resource templates
New-AzResourceGroupDeployment -ResourceGroupName $rgName -TemplateFile $HOME/az104-05-vnetvm-loop-template.json -TemplateParameterFile $HOME/az104-05-vnetvm-loop-parameters.json -location1 $location1 -location2 $location2

#Task 2: Configure local and global virtual network peering

#set the vnets

$vnet0 = Get-AzVirtualNetwork -Name 'az104-05-vnet0' -ResourceGroupName $rgName

$vnet1 = Get-AzVirtualNetwork -Name 'az104-05-vnet1' -ResourceGroupName $rgName

$vnet2 = Get-AzVirtualNetwork -Name 'az104-05-vnet2' -ResourceGroupName $rgName

#peer vnet 0 and vnet 1

Add-AzVirtualNetworkPeering -Name 'az104-05-vnet0_to_az104-05-vnet1' -VirtualNetwork $vnet0 -RemoteVirtualNetworkID $vnet1.id

Add-AzVirtualNetowkrPeering -Name 'az104-05-vnet1_to_az104-05-vnet0' -VirtualNetwork $vnet1 -RemoteVirtualNetworkID $vnet0.id

#peer vnet 0 to vnet 2

Add-AzVirtualNetowkrPeering -Name 'az104-05-vnet0_to_az104-05-vnet2' -VirtualNetowrk $vnet0 -RemoteVirtualNetworkID $vnet2.id

Add-AzVirtualNetowkrPeering -Name 'az104-05-vnet2_to_az104-05-vnet0' -VirtualNetowrk $vnet2 -RemoteVirtualNetworkID $vnet0.id

#peer vnet 1 to vnet 2

Add-AzVirtualNetowkrPeering -Name 'az104-05-vnet1_to_az104-050vnet2' -VirtualNetwork $vnet1 -RemoteVirtualNetworkID $vnet2.id

Add-AzVirtualNetowkrPeering -Name 'az104-05-vnet2_to_az104-05-vnet1' -VirtualNetowrk $vnet2 -RemoteVirtualNetworkID $vnet1.id