# Install the OpenSSH Client and Server
#Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
#Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
# Start the sshd service
#Start-Service sshd

# OPTIONAL but recommended:
Set-Service -Name sshd -StartupType 'Automatic'

# Confirm the Firewall rule is configured. It should be created automatically by setup. Run the following to verify
if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue)) {
    Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
} else {
    Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
}
# Replace Openssh cmd with PowerShell
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
# Add local adminUser
# Ask username and pass
$adminUser = Read-Host "local admin username"
$securePassword = Read-Host "local admin password" -AsSecureString

# CreateUser
New-LocalUser -Name $adminUser -Password $securePassword -FullName "Local Admin" -AccountNeverExpires
Add-LocalGroupMember -Member $adminUser -SID S-1-5-32-544 -Confirm

# add ExecutionPolicy
Start-Process powershell -Credential $adminUser -ArgumentList "-Command Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force" -NoNewWindow
