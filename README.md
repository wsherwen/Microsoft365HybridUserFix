## Overview
This PowerShell script automates the process of creating remote mailboxes in a hybrid Exchange environment, ensuring consistency between on-premises Exchange and Microsoft 365. It simplifies the process and helps prevent potential synchronization issues.

## Key Features
Automates remote mailbox creation
Handles both user and shared mailboxes
Matches Exchange GUIDs for accuracy
Provides detailed logging for troubleshooting
Validates user input for error prevention
Checks for required modules

## Usage
Prerequisites:
Exchange Online Management module: Install-Module -Name ExchangeOnlineManagement
Run the script: .\Microsoft365RemoteMailboxFix.ps1
Provide required information:
Exchange Server FQDN
Remote routing domain
Microsoft 365 UPN
Active Directory user account UPN
Shared mailbox status (yes/no)
Review logs: %windir%\Temp\Logs\Microsoft365RemoteMailboxFix.log

## Additional Notes
Ensure appropriate permissions for connecting to Exchange Online and on-premises Exchange.
Use the script responsibly and test in a non-production environment first.

## Contributing

For issues or suggestions, please create an issue in the GitHub repository.


