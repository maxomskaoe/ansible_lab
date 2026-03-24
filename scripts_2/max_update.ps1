Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
#vars
$installer_path = 'C:\Updater\'
$installer_full_path = 'C:\Updater\MAX.msi'
$download_link = 'https://trk.mail.ru/c/h172vv5'
$ignore_errors = '-ErrorAction SilentlyContinue'

IF (-not (Test-Path -Path $installer_path -ErrorAction SilentlyContinue)) {
    # IF the path doesn't exist, create directory
    New-Item -Path $installer_path -ItemType Directory
    Write-Host "Directory created"
} else {
     Write-Host "Directory already exists"
}

#remove installer 
rm $installer_full_path -ErrorAction SilentlyContinue 

#remove max app
Write-Host "Remove MAX app"
winget uninstall --Name Max --nowarn --disable-interactivity --accept-source-agreements --all-versions

#download installer
Write-Host "Download MAX" 
Invoke-WebRequest -Uri $download_link -OutFile $installer_full_path

# install with user privileges
Write-Host "Install MAX"
msiexec -i $installer_full_path ALLUSERS=2 MSIINSTALLPERUSER=1 /passive

#timeout
Start-Sleep -Seconds 10