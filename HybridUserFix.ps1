# Author: Warren Sherwen
# Last Edit: Warren Sherwen
# Verison: 1.0

$Logfile = "$env:windir\Temp\Logs\Microsoft365RemoteMailboxFix.log"
Function LogWrite{
   Param ([string]$logstring)
   Add-content $Logfile -value $logstring
   write-output $logstring
   
}
function Get-TimeStamp {
    return "[{0:dd/MM/yy} {0:HH:mm:ss}]" -f (Get-Date)
}

if (!(Test-Path "$env:windir\Temp\Logs\"))
{
   mkdir $env:windir\Temp\Logs\
   LogWrite "$(Get-TimeStamp): Script has started."
   LogWrite "$(Get-TimeStamp): Log directory created."
}
else
{
    LogWrite "$(Get-TimeStamp): Script has started."
    LogWrite "$(Get-TimeStamp): Log directory exists."
}

#PowerShell prechecks
LogWrite "$(Get-TimeStamp): Checking if Exchange Online Managment is installed."
if (!(Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
    LogWrite "$(Get-TimeStamp): ExchangeOnlineManagment Module not installed."
    LogWrite "$(Get-TimeStamp): Please run: Install-Module -Name ExchangeOnlineManagement."
    LogWrite "$(Get-TimeStamp): Script ending, powershell closing..."
    Exit
}
LogWrite "$(Get-TimeStamp): ExchangeOnlineManagment Module found."
LogWrite "$(Get-TimeStamp): No further checks required."

LogWrite "$(Get-TimeStamp): Starting upfront data collection."

#User Parameters
LogWrite "$(Get-TimeStamp): Collecting Exchange Server FQDN."
$HybridServer = Read-Host -Prompt 'Enter Exchange Servers FQDN'
LogWrite "$(Get-TimeStamp): User entered: $HybridServer."

LogWrite "$(Get-TimeStamp): Collecting the remote routing address."
$RoutingDomain = Read-Host -Prompt 'Enter the Remote Routing Domain for your Microsoft 365 tenant.'
LogWrite "$(Get-TimeStamp): User entered: $RoutingDomain."

LogWrite "$(Get-TimeStamp): Collecting the Microsoft 365 UPN."
$Microsoft365Users = Read-Host -Prompt 'Enter the Micrsoft 365 Users UPN'
LogWrite "$(Get-TimeStamp): User entered: $Microsoft365Users."

LogWrite "$(Get-TimeStamp): Collecting the Active Directory User Account UPN."
$ADUserUPN = Read-Host -Prompt 'Enter the Active Directory Users UPN'
LogWrite "$(Get-TimeStamp): User entered: $ADUserUPN."

#Shared User Question with Valadation.
do {
    LogWrite "$(Get-TimeStamp): Checking if the user is shared."
    $SharedUser = Read-Host -Prompt "Is this a Shared Mailbox? (yes/no)"
    LogWrite "$(Get-TimeStamp): User entered: $SharedUser."

  if (! ($SharedUser -match "^(yes|no)$")) {
    LogWrite "$(Get-TimeStamp): Invalid input was detected, advising the user."
    Write-Host "Invalid input. Only enter 'yes' or 'no'."
    LogWrite "$(Get-TimeStamp): Requesting valid input."
  }
} while (! ($SharedUser -match "^(yes|no)$"))

LogWrite "$(Get-TimeStamp): Valadation passed."
LogWrite "$(Get-TimeStamp): Parameter data collected."

#Connection to MS365
LogWrite "$(Get-TimeStamp): Upfront connection to MS365 Exchange Online Managment."
Connect-ExchangeOnline  -Credential $(Get-Credential)
Import-Module ExchangeOnlineManagement
 
LogWrite "$(Get-TimeStamp): Collecting data from Microsoft365."
#Retrives the Mailbox and GUID
LogWrite "$(Get-TimeStamp): Collecting Mailbox."
$Mailbox = Get-Mailbox $Microsoft365Users
LogWrite "$(Get-TimeStamp): Data Collected: $Microsoft365Users."

LogWrite "$(Get-TimeStamp): Collecting Mailbox Alias."
$Alias = $Mailbox.Alias
LogWrite "$(Get-TimeStamp): Data Collected: $Alias."

LogWrite "$(Get-TimeStamp): Collecting Exchange Guid for User."
$MSGUID = $Mailbox.ExchangeGuid
LogWrite "$(Get-TimeStamp): Data Collected: $MSGUID."

LogWrite "$(Get-TimeStamp): Upfront connection to Exchange Server."
#Conenction to Exchange Server
$LocalSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "http://$HybridServer/PowerShell/" `
      -Authentication Kerberos -Credential $(Get-Credential)
Import-PSSession $LocalSession -CommandName Enable-RemoteMailbox, Set-RemoteMailbox
 
LogWrite "$(Get-TimeStamp): Creating Remote Mailbox on Exchange."
#Creates a Remote Mailbox
if ($userIsShared -eq "yes") {
    LogWrite "$(Get-TimeStamp): Shared Mailbox requested, creating the mailbox."
    Enable-RemoteMailbox -Shared $ADUserUPN -Alias $Alias -RemoteRoutingAddress "$Alias@$RoutingDomain"
    LogWrite "$(Get-TimeStamp): Remote Mailbox Created."
} else {
    LogWrite "$(Get-TimeStamp): User Mailbox requested, creating the mailbox."
    Enable-RemoteMailbox $ADUserUPN -Alias $Alias -RemoteRoutingAddress "$Alias@$RoutingDomain"
    LogWrite "$(Get-TimeStamp): Remote Mailbox Created."
}

LogWrite "$(Get-TimeStamp): Setting exchange guid on $Alias."
#Matches the GUID
Set-RemoteMailbox $Alias -ExchangeGuid $MSGUID
LogWrite "$(Get-TimeStamp): GUID has been set to $MSGUID."

LogWrite "$(Get-TimeStamp): Script ending, powershell closing..."
#Terminate the session
Get-PSSession | Remove-PSSession

#Terminates the Script
Read-Host -Prompt “Press Enter to exit”
Exit
