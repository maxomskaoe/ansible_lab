Write-Host "Install ssh windows" -ForegroundColor Green

# Folders/directories
$sourceDir = "C:\Users\maxomskaoe\windows_install"
$installDir = "C:\Install\OpenSSH-Win64"
$programDataSsh = "C:\ProgramData\ssh"
$userSshDir = "C:\Users\maxomskaoe\.ssh"

# 1. copy OpenSSH into C:\Install
Write-Host "1. copy files..." -ForegroundColor Yellow
if (!(Test-Path "C:\Install")) { New-Item "C:\Install" -ItemType Directory -Force | Out-Null }
Copy-Item -Path "$sourceDir\OpenSSH-Win64" -Destination "C:\Install\" -Recurse -Force
Write-Host "✅ OpenSSH copied"

# 2. install SSH
Write-Host "2. installing services..." -ForegroundColor Yellow
Set-Location $installDir
& .\install-sshd.ps1
Write-Host "✅ SSH installed"

# 3. Copy configs
Write-Host "3. Copy Settings..." -ForegroundColor Yellow
Copy-Item "$sourceDir\sshd_config" "$programDataSsh\" -Force
Copy-Item "$sourceDir\administrators_authorized_keys" "$programDataSsh\" -Force
Write-Host "✅ Settings copied"

# 4. Create user .ssh folder and copy authorized_keys
Write-Host "4. Setup user SSH keys..." -ForegroundColor Yellow
if (!(Test-Path $userSshDir)) {
    New-Item -Path $userSshDir -ItemType Directory -Force | Out-Null
    Write-Host "   ✅ Created $userSshDir"
}

# Copy same key to user's authorized_keys
Copy-Item "$sourceDir\administrators_authorized_keys" "$userSshDir\authorized_keys" -Force
Write-Host "   ✅ Key copied to $userSshDir\authorized_keys"

# 5. Keys permissions for admin key
Write-Host "5. Set admin key permissions..." -ForegroundColor Yellow
icacls "$programDataSsh\administrators_authorized_keys" /inheritance:r
icacls "$programDataSsh\administrators_authorized_keys" /grant "SYSTEM:(F)"
icacls "$programDataSsh\administrators_authorized_keys" /grant "S-1-5-32-544:(F)"
icacls "$programDataSsh\administrators_authorized_keys" /grant "NT SERVICE\sshd:(R)"
Write-Host "✅ Admin key permissions ready"

# 6. Start_Services
Write-Host "6. Start SSH..." -ForegroundColor Yellow
Set-Service sshd -StartupType Automatic
Set-Service ssh-agent -StartupType Automatic
Start-Service sshd
Start-Service ssh-agent
Write-Host "✅ SSH works"

# 7. Check
Write-Host "Ready!" -ForegroundColor Green
Write-Host "Status: $(Get-Service sshd | Select-Object -ExpandProperty Status)"
Write-Host "Port 22: $(netstat -an | findstr :22)"
