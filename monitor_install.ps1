# Monitor Android Studio installation status
$timeout = 3600  # Max wait 1 hour
$elapsed = 0
$checkInterval = 30  # Check every 30 seconds

Write-Host "========================================"
Write-Host "Monitoring Android Studio installation..."
Write-Host "Checking every $checkInterval seconds, max wait $($timeout/60) minutes"
Write-Host "========================================"
Write-Host ""

$paths = @(
    "C:\Program Files\Android\Android Studio",
    "C:\Program Files (x86)\Android\Android Studio",
    "$env:LOCALAPPDATA\Android\Android Studio"
)

while ($elapsed -lt $timeout) {
    $installed = $false
    $installedPath = $null
    
    foreach ($path in $paths) {
        if (Test-Path $path) {
            $installed = $true
            $installedPath = $path
            break
        }
    }
    
    $time = Get-Date -Format "HH:mm:ss"
    
    if ($installed) {
        Write-Host ""
        Write-Host "SUCCESS! Android Studio installed at $time"
        Write-Host "Path: $installedPath"
        Write-Host ""
        Write-Host "Next steps:"
        Write-Host "  1. Start Android Studio"
        Write-Host "  2. Complete SDK setup wizard"
        Write-Host "  3. Install command-line tools in SDK Manager"
        Write-Host "  4. Run '启动Flutter版.bat' to build APK"
        Write-Host ""
        break
    } else {
        Write-Host "[$time] Still installing... waited $elapsed seconds"
    }
    
    Start-Sleep -Seconds $checkInterval
    $elapsed += $checkInterval
}

if (-not $installed) {
    Write-Host ""
    Write-Host "Timeout! Installation may be stuck"
    Write-Host "Please check manually or reinstall"
}

Write-Host ""
Write-Host "Press Enter to exit"
$null = Read-Host
