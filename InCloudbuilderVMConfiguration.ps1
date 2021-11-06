# In Cloudbuilder Base VM aka ASH VM

Set-Item wsman:localhost\client\trustedhosts -Value *
Enable-WSManCredSSP -Role Client -DelegateComputer *

# Set Group Policy
# Open the gpedit.msc console and navigate to: 
# Local Computer Policy > Computer Configuration > Administrative Templates > System > Credential Delegation
# Then:
# Activate Allow Delegating Fresh Credentials with NTLM-only Server Authentication and add the value WSMAN/*. Launch the script again:

$AdminPassword = ConvertTo-SecureString 'YourPassword' -AsPlainText -Force

.\InstallAzureStackPOC.ps1 -DNSForwarder 8.8.8.8 -TimeServer 129.6.15.28 -AdminPassword $AdminPassword

# Rename ASH VM

# Setup Enhanced Session for cut and paste in Hyper

# Helpful Fix if you see this issue:
# https://www.cryingcloud.com/blog/2021/2/17/asdk-2008-install-fix

# Added a D drive to the end of the OS Disk
# Deploy will fail for sure without this!
# https://social.msdn.microsoft.com/Forums/azure/en-US/f4aef4b3-092d-4f45-afcb-36cf6c862720/the-system-cannot-find-the-path-specified-the-related-filedirectory-is?forum=AzureStack
