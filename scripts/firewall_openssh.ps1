# Remove all existing SSH-related firewall rules
Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*ssh*" -or $_.DisplayName -like "*SSH*"} | Remove-NetFirewallRule -ErrorAction SilentlyContinue

# Create new rule allowing SSH from localhost (for testing) and specific Linux host
New-NetFirewallRule -DisplayName "SSH Server - Linux Only + Localhost" `
                    -Description "Allow SSH from localhost and 192.168.1.186" `
                    -Direction Inbound `
                    -Protocol TCP `
                    -LocalPort 22 `
                    -RemoteAddress "127.0.0.1", "192.168.1.186" `
                    -Action Allow `
                    -Profile Any `
                    -Enabled True

# Verify the new rule
Write-Host "Firewall rules for SSH configured:" -ForegroundColor Green
Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*SSH*"} | 
    Select-Object DisplayName, Direction, Action, Enabled | 
    Format-Table -AutoSize

Get-NetFirewallRule -DisplayName "SSH Server - Linux Only + Localhost" | 
    Get-NetFirewallAddressFilter | 
    Format-List RemoteAddress
