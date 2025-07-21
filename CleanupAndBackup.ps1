Add-Type -AssemblyName System.Windows.Forms

# === CONFIGURATION ===
$backupSource = "$env:USERPROFILE\Documents"
$backupTarget = "C:\Backup\Documents_Backup_$((Get-Date).ToString('yyyyMMdd_HHmm'))"

# === STEP 2: Clear System Junk ===
Write-Output "Cleaning Temp files..."
Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

Write-Output "Emptying Recycle Bin..."
Clear-RecycleBin -Force -ErrorAction SilentlyContinue

Write-Output "Clearing Windows Update leftovers..."
Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue

# === STEP 3: Clear Browser Data ===

Write-Output "Stopping browsers..."
Get-Process brave, msedge -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3

Write-Output "Clearing Edge cache and cookies..."
Remove-Item "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cookies" -Force -ErrorAction SilentlyContinue

Write-Output "Clearing Brave cache and cookies..."
Remove-Item "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Cookies" -Force -ErrorAction SilentlyContinue

# Shutdown
Stop-Computer -Force
