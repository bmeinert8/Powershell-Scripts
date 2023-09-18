#LAB 04 IMPLEMENT VIRTUAL NETWORKING

#Task 1 Create and configure a virtual network

#create teh resource group
$rgName = 'az104-04-rg1'
$location = 'eastus'
New-AzResourceGroup -Name $rgName -Location $location

#create the subnets
$subnet0 = New-AzVirtualNetworkSubnetConfig -Name 'subnet0' -AddressPrefix '10.40.0.0/24'
$subnet1 = New-AzVirtualNetworkSubnetConfig -Name 'subnet1' -AddressPrefix '10.40.1.0/24'

#create the virtual network
$vnet = New-AzVirtualNetwork -Name 'az104-04-vnet1' -ResourceGroupName $rgName -Location $location -AddressPrefix '10.40.0.0/20' -Subnet $subnet0, $subnet1

#Task 2: Deploy virtual machines into the virtual network from json file

New-AzResourceGroupDeployment -ResourceGroupName $rgName -TemplateFile $HOME/az104-04-vms-loop-template.json -TemplateParameterFile $HOME/az104-04-vms-loop-parameters.json

#Task 3: Configure private and public IP adresses of Azure VMs

#create public IP 0
$ip0 = New-AzPublicIpAddress -Name 'az104-04-pip0' -ResourceGroupName $rgName -Location $location -Sku 'Basic' -AllocationMethod 'Static' -IpAddressVersion 'IPv4'

#create public IP 1
$ip1 = = New-AzPublicIpAddress -Name 'az104-04-pip1' -ResourceGroupName $rgName -Location $location -Sku 'Basic' -AllocationMethod 'Static' -IpAddressVersion 'IPv4'

#get nic's
$nic0 = Get-AzNetworkInterface -Name 'az104-04-nic0' -ResourceGroupName $rgName
$nic1 = Get-AzNetworkInterface -Name 'az104-04-nic1' -ResourceGroupName $rgName
#set the ip config
$nic0 | Set-AzNetworkInterfaceIPConfig -Name 'ipconfig1' -PublicIPAddress $ip0 -subnet $subnet0 -AllocationMethod 'Static'
$nic1 | Set-AzNetworkInterfaceIPConfig -Name 'ipconfig1' -PublicIPAddress $ip1 -subnet $subnet1 -AllocationMethod 'Static'

#Task 4: Configure network security groups

#stop VM0 and 1
Stop-AzVM -ResourceGroupName $rgName -Name "az104-04-vm0"
Stop-AzVM -ResourceGroupName $rgName -Name "az104-04-vm1"

#Create a network Security Group
$networkSecurityGroup = New-AzNetworkSecurityGroup -Name 'az104-04-nsg01' -ResourceGroupName $rgName  -Location  $location

# Create the security rule
Add-AzNetworkSecurityRuleConfig -Name "RDP-rule" -NetworkSecurityGroup $networkSecurityGroup -Description "Allow RDP" -Access 'Allow' -Protocol 'Tcp' -Direction 'Inbound' -Priority '300' -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389

#Updates the network security group.
Set-AzNetworkSecurityGroup -NetworkSecurityGroup $networkSecurityGroup

#associate nsg to nic's
$nic0.NetworkSecurityGroup = $networkSecurityGroup
$nic0 | Set-AzNetworkInterface -Networkinterface $nic0

$nic1.NetworkSecurityGroup = $networkSecurityGroup
$nic1 | Set-AzNetworkInterface -Networkinterface $nic1

#start the vms
Start-AzVM -ResourceGroupName $rgName -Name "az104-04-vm0"
Start-AzVM -ResourceGroupName $rgName -Name "az104-04-vm1"


