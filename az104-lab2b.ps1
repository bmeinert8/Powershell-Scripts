#LAB 02B MANAGE GOVERNANCE VIA AZURE POLICY
#Task 1 Assign Tags

#Create the tags
$tags = @{"Role"="Infra"}

#assign the resource
$resource = Get-AzResource -Name "cloudshellstorageeus1621" -ResourceGroup "Cloud-shell-eastus"

#apply the tag
New-AzTag -ResourceId $resource.id -Tag $tags 

#Task 3 inherit tag from resource group
#apply inherit tag from resource group policy 
#apply tags to resource group
$ResourceGroup = Get-AzResourceGroup -Name "Cloud-shell-eastus"
New-AzTag -ResourceId $ResourceGroup.ResourceId -Tag $tags

#Create storage account to inherit the tags from the RG
New-AzStorageAccount -ResourceGroupName "Cloud-shell-eastus" `
  -Name "lab02astrgacct" `
  -Location "eastus" `
  -SkuName Standard_RAGRS `
  -Kind StorageV2

#check to make sure tags are inherited
Get-AzResource -Name "lab03astrgacct" -ResourceGroup "Cloud-shell-eastus"