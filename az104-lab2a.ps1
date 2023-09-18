# LAB 2A MANAGE SUBSCRIPTIOS AND RBAC
#TASK 1 Create a management group

#Create new management group
New-AzManagementGroup -GroupName "az104-02-mg1" -DisplayName "az104-02-mg1"

#Move subscriptio into new management group
$subscription = Get-AzSubscription -SubscriptionName "Azure for Students"
New-AzManagementGroupSubscription -GroupId 'az104-02-mg1' -SubscriptionId $subscription.id

#TASK 2 Create Custom RBAC Roles

New-AzRoleDefinition -InputFile $HOME/az104-02a-customRoleDefinition.json

#TASK 3 assign the new RBAC

#create new user for roll
Connect-AzureAD
$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$PasswordProfile.Password = "<password>"
New-AzureADUser -DisplayName "az104-02-aaduser1" -PasswordProfile $PasswordProfile -UserPrincipalName "az104-02-aaduser1@.onmicrosoft.com" -MailNickname "az104-02-aaduser1" -AccountEnabled $true

#assign role to new user
Get-AzRoleDefinition -Name "Support Request Contributor (custom)"
Get-AzADUser
New-AzRoleAssignment -SignInName az104-02-aaduser1@.onmicrosoft.com `
-RoleDefinitionName "Support Request Contributor (Custom)" `
-Scope /providers/Microsoft.Management/managementGroups/az104-02-mg1
