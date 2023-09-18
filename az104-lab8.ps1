#LAB 08 MANAGE VIRTUAL MACHINES
#Task 1: Deploy zone-resilient Azure virtual machines

# Create Resource Group
$rgName = 'az104-08-rg01'
$location = 'eastus'
New-AzResourceGroup -Name $rgName -Location $location

# Create admin credentials
$cred = Get-Credential -Message "Enter a username and password for the virtual machine."

# Create a VM
$vmParams = @{
    ResourceGroupName = $rgName
    Name = 'az104-08-vm0'
    Location = $location
    Zone = 1
    ImageName = 'Win2019Datacenter'
    Credential = $cred
    Size = 'Standard_D2s_v3'
    VirtualNetworkName = 'az104-08-vnet1'
    AddressPrefix = 10.80.0.0/20
    SubnetName = 'subnet0'
    SubnetAddressPrefix = 10.80.0.0/24
}

$newVM1 = New-AzVM @vmParam 

#connect to VM install IIS
powershell.exe Install-WindowsFeature -name Web-Server -IncludeManagementTools
powershell.exe Remove-Item -Path 'C:\inetpub\wwwroot\iisstart.htm'
powershell.exe Add-Content -Path 'C:\inetpub\wwwroot\iisstart.htm' -Value "$env:computername"




