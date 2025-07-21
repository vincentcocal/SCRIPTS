Add-Type -AssemblyName System.Windows.Forms

# Notify Start
[System.Windows.Forms.MessageBox]::Show("Starting PC Maintenance. This may take a few minutes...", "PC Cleaner", 0, 'Information')

# 1. Clean Temp Files
Write-Output "Cleaning temp files..."
Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

# 2. Empty Recycle Bin
Write-Output "Emptying Recycle Bin..."
Clear-RecycleBin -Force -ErrorAction SilentlyContinue

# 3. Clear Browser Cache
Write-Output "Clearing browser caches..."
# Edge
Remove-Item "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
# Chrome
Remove-Item "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue

# 4. Clean Windows Update leftovers
Write-Output "Cleaning SoftwareDistribution folder..."
Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue

# 5. Run System File Checker
Write-Output "Running SFC..."
Start-Process powershell -ArgumentList "sfc /scannow" -Verb RunAs -Wait

# 6. Run CHKDSK
Write-Output "Scheduling CHKDSK on next boot..."
cmd.exe /c "echo Y | chkdsk C: /F /R"

# 7. Run Defrag (for HDD only — skipped on SSDs automatically)
Write-Output "Running defrag..."
defrag C: /O

# Notify Done
[System.Windows.Forms.MessageBox]::Show("Maintenance complete. A restart is recommended for CHKDSK to run.", "PC Cleaner", 0, 'Information')
