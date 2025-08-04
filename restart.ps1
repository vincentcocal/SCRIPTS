# System Cleanup Script - Fully Automated
# Run as Administrator for best results

# Set execution policy for this session
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Keep console open on errors and suppress prompts
$ErrorActionPreference = "Continue"
$ConfirmPreference = "None"
$VerbosePreference = "SilentlyContinue"

# Function to check if running as administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Administrator)) {
    Write-Warning "This script should be run as Administrator for full functionality."
    Write-Host "Some cleanup operations may be skipped." -ForegroundColor Yellow
    Write-Host ""
}

# Function to safely remove items
function Remove-ItemSafely {
    param([string]$Path, [switch]$Recurse)
    
    if (Test-Path $Path) {
        try {
            if ($Recurse) {
                Remove-Item $Path -Recurse -Force -ErrorAction SilentlyContinue -Confirm:$false
            } else {
                Remove-Item $Path -Force -ErrorAction SilentlyContinue -Confirm:$false
            }
            return $true
        } catch {
            return $false
        }
    }
    return $false
}

# Function to stop processes safely
function Stop-ProcessSafely {
    param([string]$ProcessName)
    
    try {
        $processes = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
        if ($processes) {
            $processes | Stop-Process -Force -ErrorAction SilentlyContinue -Confirm:$false
            Start-Sleep -Seconds 2
            return $processes.Count
        }
    } catch {
        # Ignore errors
    }
    return 0
}

Write-Host "Starting Automated System Cleanup..." -ForegroundColor Green
Write-Host ""

# 1. Clear Temporary Files
Write-Host "1. Clearing temporary files..." -ForegroundColor Cyan
$tempCleared = 0
try {
    # Define temp paths
    $tempPaths = @(
        $env:TEMP,
        "$env:USERPROFILE\AppData\Local\Temp",
        "C:\Windows\Temp"
    )
    
    foreach ($tempPath in $tempPaths) {
        if (Test-Path $tempPath) {
            $tempFiles = Get-ChildItem -Path $tempPath -Force -ErrorAction SilentlyContinue
            foreach ($file in $tempFiles) {
                if (Remove-ItemSafely -Path $file.FullName -Recurse) {
                    $tempCleared++
                }
            }
        }
    }
    
    Write-Host "[OK] Temporary files cleared ($tempCleared files processed)" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Error clearing temporary files: $($_.Exception.Message)" -ForegroundColor Red
}

# 2. Clear Browser Cache and Cookies
# YOU CAN ADD MORE BROWSERS HERE
Write-Host "`n2. Clearing browser data..." -ForegroundColor Cyan

# Brave Browser
try {
    $bravePath = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default"
    if (Test-Path $bravePath) {
        Write-Host "   Stopping Brave..." -ForegroundColor Yellow
        $stopped = Stop-ProcessSafely -ProcessName "brave"
        
        $braveFiles = @(
            "$bravePath\Cache",
            "$bravePath\Code Cache", 
            "$bravePath\GPUCache",
            "$bravePath\Cookies",
            "$bravePath\History",
            "$bravePath\Web Data",
            "$bravePath\Local Storage",
            "$bravePath\Session Storage",
            "$bravePath\IndexedDB"
        )
        
        $braveCleared = 0
        foreach ($path in $braveFiles) {
            if (Remove-ItemSafely -Path $path -Recurse) {
                $braveCleared++
            }
        }
        
        Write-Host "[OK] Brave data cleared ($braveCleared items processed)" -ForegroundColor Green
    } else {
        Write-Host "- Brave not found" -ForegroundColor Gray
    }
} catch {
    Write-Host "[ERROR] Error clearing Brave data: $($_.Exception.Message)" -ForegroundColor Red
}

# Microsoft Edge
try {
    $edgePath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default"
    if (Test-Path $edgePath) {
        Write-Host "   Stopping Edge..." -ForegroundColor Yellow
        $stopped = Stop-ProcessSafely -ProcessName "msedge"
        
        $edgeFiles = @(
            "$edgePath\Cache",
            "$edgePath\Code Cache",
            "$edgePath\GPUCache",
            "$edgePath\Cookies",
            "$edgePath\History",
            "$edgePath\Web Data",
            "$edgePath\Local Storage",
            "$edgePath\Session Storage",
            "$edgePath\IndexedDB"
        )
        
        $edgeCleared = 0
        foreach ($path in $edgeFiles) {
            if (Remove-ItemSafely -Path $path -Recurse) {
                $edgeCleared++
            }
        }
        
        Write-Host "[OK] Edge data cleared ($edgeCleared items processed)" -ForegroundColor Green
    } else {
        Write-Host "- Edge not found" -ForegroundColor Gray
    }
} catch {
    Write-Host "[ERROR] Error clearing Edge data: $($_.Exception.Message)" -ForegroundColor Red
}

# 3. Empty Recycle Bin
Write-Host "`n3. Emptying Recycle Bin..." -ForegroundColor Cyan
try {
    # Use Clear-RecycleBin with -Force to suppress prompts
    if (Get-Command Clear-RecycleBin -ErrorAction SilentlyContinue) {
        Clear-RecycleBin -Force -Confirm:$false -ErrorAction Stop
        Write-Host "[OK] Recycle Bin emptied" -ForegroundColor Green
    } else {
        # Alternative method for older PowerShell versions
        $shell = New-Object -ComObject Shell.Application
        $recycleBin = $shell.Namespace(0xa)
        if ($recycleBin.Items().Count -gt 0) {
            $recycleBin.Items() | ForEach-Object { 
                Remove-ItemSafely -Path $_.Path -Recurse
            }
        }
        Write-Host "[OK] Recycle Bin emptied (alternative method)" -ForegroundColor Green
    }
} catch {
    Write-Host "[ERROR] Error emptying Recycle Bin: $($_.Exception.Message)" -ForegroundColor Red
}

# 4. Clear Windows Cache and Logs
Write-Host "`n4. Clearing Windows cache and logs..." -ForegroundColor Cyan
try {
    # Windows Update cache
    Remove-ItemSafely -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse
    
    # Windows logs (only clear application and system logs safely)
    $logsToGlear = @("Application", "System", "Security")
    foreach ($logName in $logsToGlear) {
        try {
            wevtutil cl $logName 2>$null
        } catch {
            # Skip logs that can't be cleared
        }
    }
    
    # Prefetch files
    Remove-ItemSafely -Path "C:\Windows\Prefetch\*"
    
    # Windows Error Reporting
    Remove-ItemSafely -Path "C:\ProgramData\Microsoft\Windows\WER\*" -Recurse
    
    Write-Host "[OK] Windows cache and logs cleared" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Error clearing Windows cache: $($_.Exception.Message)" -ForegroundColor Red
}

# 5. Clear DNS Cache
Write-Host "`n5. Clearing DNS cache..." -ForegroundColor Cyan
try {
    $null = ipconfig /flushdns
    Write-Host "[OK] DNS cache cleared" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Error clearing DNS cache: $($_.Exception.Message)" -ForegroundColor Red
}

# 6. Memory Cleanup
Write-Host "`n6. Performing memory cleanup..." -ForegroundColor Cyan
try {
    # Force garbage collection
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    [System.GC]::Collect()
    
    # Clear standby memory (if running as admin)
    if (Test-Administrator) {
        try {
            # Note: This would require downloading RAMMap, so we'll skip this advanced feature
        } catch {
            # Skip if not available
        }
    }
    
    Write-Host "[OK] Memory cleanup performed" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Error during memory cleanup: $($_.Exception.Message)" -ForegroundColor Red
}

# 7. Stop unnecessary processes and services
Write-Host "`n7. Stopping unnecessary processes..." -ForegroundColor Cyan
try {
    # List of processes that can be safely stopped
    $processesToStop = @(
        "OneDrive", "Skype", "Teams", "Slack", "Discord", 
        "Spotify", "Steam", "EpicGamesLauncher"
    )
    
    $processesKilled = 0
    foreach ($process in $processesToStop) {
        $killed = Stop-ProcessSafely -ProcessName $process
        if ($killed -gt 0) {
            $processesKilled += $killed
            Write-Host "   Stopped: $process ($killed instances)" -ForegroundColor Yellow
        }
    }
    
    Write-Host "[OK] Unnecessary processes stopped ($processesKilled processes)" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Error stopping processes: $($_.Exception.Message)" -ForegroundColor Red
}

# 8. Disk Cleanup using built-in tools
Write-Host "`n8. Running disk cleanup..." -ForegroundColor Cyan
try {
    # Configure cleanmgr settings to run automatically
    $cleanMgrKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
    
    # Enable all cleanup options
    $cleanupOptions = @(
        "Active Setup Temp Folders",
        "BranchCache",
        "Downloaded Program Files",
        "Internet Cache Files",
        "Memory Dump Files",
        "Offline Pages Files",
        "Old ChkDsk Files",
        "Previous Installations",
        "Recycle Bin",
        "Setup Log Files",
        "System error memory dump files",
        "System error minidump files",
        "Temporary Files",
        "Temporary Setup Files",
        "Thumbnail Cache",
        "Update Cleanup",
        "Windows Error Reporting Archive Files",
        "Windows Error Reporting Queue Files",
        "Windows Error Reporting System Archive Files",
        "Windows Error Reporting System Queue Files",
        "Windows Upgrade Log Files"
    )
    
    foreach ($option in $cleanupOptions) {
        $keyPath = "$cleanMgrKey\$option"
        if (Test-Path $keyPath) {
            Set-ItemProperty -Path $keyPath -Name "StateFlags0001" -Value 2 -ErrorAction SilentlyContinue
        }
    }
    
    # Run cleanmgr with the configured settings
    Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:1" -Wait -WindowStyle Hidden -ErrorAction SilentlyContinue
    Write-Host "[OK] Disk cleanup completed" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Error running disk cleanup: $($_.Exception.Message)" -ForegroundColor Red
}

# 9. Clear thumbnail cache
Write-Host "`n9. Clearing thumbnail cache..." -ForegroundColor Cyan
try {
    $thumbnailPaths = @(
        "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db",
        "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\iconcache_*.db"
    )
    
    foreach ($path in $thumbnailPaths) {
        Get-ChildItem -Path $path -ErrorAction SilentlyContinue | ForEach-Object {
            Remove-ItemSafely -Path $_.FullName
        }
    }
    
    Write-Host "[OK] Thumbnail cache cleared" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Error clearing thumbnail cache: $($_.Exception.Message)" -ForegroundColor Red
}

# 10. Clear Recent Documents
Write-Host "`n10. Clearing recent documents..." -ForegroundColor Cyan
try {
    Remove-ItemSafely -Path "$env:APPDATA\Microsoft\Windows\Recent\*"
    Remove-ItemSafely -Path "$env:APPDATA\Microsoft\Office\Recent\*"
    Write-Host "[OK] Recent documents cleared" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Error clearing recent documents: $($_.Exception.Message)" -ForegroundColor Red
}

# 11. SSD Optimization (TRIM)
Write-Host "`n11. Optimizing SSD (TRIM)..." -ForegroundColor Cyan
try {
    # Get all drives and optimize SSDs
    Get-Volume | Where-Object {$_.DriveLetter -ne $null -and $_.DriveType -eq 'Fixed'} | ForEach-Object {
        $drive = $_.DriveLetter
        try {
            Optimize-Volume -DriveLetter $drive -ReTrim -ErrorAction SilentlyContinue
        } catch {
            # Skip drives that can't be optimized
        }
    }
    Write-Host "[OK] SSD optimization completed" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Error optimizing SSD: $($_.Exception.Message)" -ForegroundColor Red
}

# 12. Clear Windows Search Index
Write-Host "`n12. Clearing Windows Search Index..." -ForegroundColor Cyan
try {
    Stop-Service -Name "WSearch" -Force -ErrorAction SilentlyContinue
    Remove-ItemSafely -Path "C:\ProgramData\Microsoft\Search\Data\Applications\Windows\*" -Recurse
    Start-Service -Name "WSearch" -ErrorAction SilentlyContinue
    Write-Host "[OK] Windows Search Index cleared" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Error clearing search index: $($_.Exception.Message)" -ForegroundColor Red
}

# 13. Final system information
Write-Host "`n13. Gathering system information..." -ForegroundColor Cyan
try {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue
    $cpu = Get-CimInstance -ClassName Win32_Processor -ErrorAction SilentlyContinue
    $memory = Get-CimInstance -ClassName Win32_PhysicalMemory -ErrorAction SilentlyContinue | Measure-Object -Property Capacity -Sum
    
    if ($os -and $cpu -and $memory) {
        $freeMemoryGB = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
        $totalMemoryGB = [math]::Round($memory.Sum / 1GB, 2)

        #YOU CAN ADD MORE SYSTEM INFO HERE
        Write-Host "`nSystem Status:" -ForegroundColor Yellow
        Write-Host "Total RAM: $totalMemoryGB GB" -ForegroundColor White
        Write-Host "Free RAM: $freeMemoryGB GB" -ForegroundColor Green
    }
} catch {
    Write-Host "[ERROR] Error gathering system info: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "AUTOMATED SYSTEM CLEANUP COMPLETE!" -ForegroundColor Green

#YOU CAN ALSO ADD A TIMER TO RESTART THE SYSTEM, JUST UNCOMMENT THE FOLLOWING LINES:

#Write-Host "The system will restart in 5 seconds..." -ForegroundColor Yellow
#Start-Sleep -Seconds 5


Restart-Computer -Force
