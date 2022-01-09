#User Parameters
$HybridServer = Read-Host -Prompt 'Enter Hybrid Server FQDN'
$RoutingDomain = Read-Host -Prompt 'Enter the Remote Routing Domain for MS 365'
$Office365User = Read-Host -Prompt 'Enter the Office365 Users UPN'

#Set the UPN of the MS365 Mailbox
$MS365UPN = $Office365User

#Sets teh Local exchange server
$ExServer = $HybridServer

#Sets the Remote Routing Domain
$RRD = $RoutingDomain
 
#Connection to MS365
$RemoteSession = New-PSSession -ConfigurationName Microsoft.Exchange `
      -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $(Get-Credential) `
      -Authentication Basic -AllowRedirection
Import-PSSession $RemoteSession -CommandName Get-Mailbox
 
#Conenction to Hybrid Server
$LocalSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "http://$ExServer/PowerShell/" `
      -Authentication Kerberos -Credential $(Get-Credential)
Import-PSSession $LocalSession -CommandName Enable-RemoteMailbox, Set-RemoteMailbox
 
#Retrives the Mailbox and GUID
$Mailbox = Get-Mailbox $MS365UPN
$Alias = $Mailbox.Alias
$MSGUID = $Mailbox.ExchangeGuid
 
#Creates a Remote Mailbox
Enable-RemoteMailbox $MS365UPN -Alias $Alias -RemoteRoutingAddress "$Alias@$RRD"

#Matches the GUID
Set-RemoteMailbox $Alias -ExchangeGuid $MSGUID
 
#Terminate the session
Get-PSSession | Remove-PSSession

#Terminates the Script
Read-Host -Prompt “Press Enter to exit”