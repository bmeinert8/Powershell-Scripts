#AZ-104 LAB 01 MANAGE AZURE ACTIVE DIRECTORY IDENTITIES

#TASK 1: CREATE AND CONFIGURE AZURE AD USERS

#Connect ot Azure Tennant
Connect-AzureAD -TennantId <tennant Id number>

#Create pasword profile
$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$PasswordProfile.Password = "<password>"

#Create New User1
New-AzureADUser -DisplayName "az104-01a-aaduser1" -PasswordProfile $PasswordProfile -UserPrincipalName "az104-01a-aaduser1@.onmicrosoft.com" -MailNickname "az104-01a-aaduser1" -JobTitle "Cloud Administrator" -Department "IT" -UsageLocation "US" -AccountEnabled $true

#Creat New User2
New-AzureADUser -DisplayName "az104-01a-aaduser2" -PasswordProfile $PasswordProfile -UserPrincipalName "az104-01a-aaduser2@.onmicrosoft.com" -MailNickname "az104-01a-aaduser2" -JobTitle "System Administrator" -Department "IT" -UsageLocation "US" -AccountEnabled $true


#TASK 2: CREATE AZURE AD GROUPS WITH ASSIGNED AND DYNAMIC MEMBERSHIPS

#create a dynamic membership
#need azure p2 license to create dynamic group
#need to import Azure AD Preview model to create the dynamic group

Import-Module AzureADPreview

#create dynamic group 1
New-AzureADMSGroup -DisplayName "IT Cloud Administrators" -Description "Dynamic group created from PS" -MailEnabled $False -MailNickname "Cloud Administrators" -SecurityEnabled $True -GroupTypes "DynamicMembership" -MembershipRule "(user.jobTitle -eq ""Cloud Administrator"")" -MembershipRuleProcessingState "On"

#create dynamic group 2
New-AzureADMSGroup -DisplayName "IT System Administrators" -Description "Dynamic group created from PS" -MailEnabled $False -MailNickname "System Administrators" -SecurityEnabled $True -GroupTypes "DynamicMembership" -MembershipRule "(user.jobTitle -eq ""System Administrator"")" -MembershipRuleProcessingState "On"

#create an assigned group
New-AzureADGroup -DisplayName "IT Lab Administrators" -MailEnabled $false -SecurityEnabled $true -MailNickName "Lab Administrators"

#Add Cloud Admin and System Admin groups to lab admin group
Add-AzureADGroupMember -ObjectId "target group id" -RefObjectId "member id"

#run get command to get groups if needed id
Get-AzureADGroup -All:$true

#TASK 3 INVITE A GUEST USER
New-AzureADMSInvitation -InvitedUserDisplayName "az104-01b-aaduser1" -InvitedUserEmailAddress someexternaluser@externaldomain.com -SendInvitationMessage $True -InviteRedirectUrl "http://myapps.microsoft.com"