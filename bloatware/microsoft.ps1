# Remove Microsoft bloatware applications
# Script is re-runnable - missing apps are skipped silently
# Uses AppX removal for Windows Store apps
# Can run without admin (removes for current user only)

$appIds = @(
    # Entertainment & Gaming
    "Microsoft.GamingApp"
    "Microsoft.XboxGamingOverlay"
    "Microsoft.Xbox.TCUI"
    "Microsoft.XboxIdentityProvider"
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.MicrosoftSolitaireCollection"

    # Productivity (optional)
    ## "Microsoft.Teams"
    "Microsoft.OutlookForWindows"
    ## "Microsoft.MicrosoftOfficeHub"
    ## "Microsoft.Todos"
    "Microsoft.PowerAutomateDesktop"

    # Utilities
    "Clipchamp.Clipchamp"
    "Microsoft.YourPhone"
    "MicrosoftCorporationII.QuickAssist"
    "MicrosoftWindows.Client.WebExperience" # Windows Web Experience Pack (Widgets)
    ## "Microsoft.WindowsFeedbackHub"
    ## "Microsoft.GetHelp"

    # News & Weather
    "Microsoft.BingNews"
    "Microsoft.BingWeather"
    "Microsoft.BingSearch"

    # Media & Apps
    ## "Microsoft.WindowsCamera"
    "Microsoft.WindowsSoundRecorder"
    ## "Microsoft.MicrosoftStickyNotes"
    ## "Microsoft.Paint"
)

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "⚠ Not running as Administrator - will remove apps for current user only" -ForegroundColor Yellow
    Write-Host "  To remove for all users, run PowerShell as Administrator`n" -ForegroundColor Yellow
}

foreach ($appId in $appIds) {
    Write-Host "Attempting to remove: $appId" -ForegroundColor Cyan
    
    # Find the AppX package - current user or all users depending on privileges
    if ($isAdmin) {
        $packages = Get-AppxPackage -Name $appId -AllUsers -ErrorAction SilentlyContinue
    }
    else {
        $packages = Get-AppxPackage -Name $appId -ErrorAction SilentlyContinue
    }
    
    if ($packages) {
        foreach ($package in $packages) {
            try {
                if ($isAdmin) {
                    # Remove for all users
                    Remove-AppxPackage -Package $package.PackageFullName -AllUsers -ErrorAction Stop
                    Write-Host "✓ Removed: $appId (all users)" -ForegroundColor Green
                }
                else {
                    # Remove for current user only
                    Remove-AppxPackage -Package $package.PackageFullName -ErrorAction Stop
                    Write-Host "✓ Removed: $appId (current user)" -ForegroundColor Green
                }
            }
            catch {
                Write-Host "  Failed to remove: $appId - $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
    }
    else {
        Write-Host "  Skipped: $appId (not installed)" -ForegroundColor Gray
    }
}

Write-Host "`nBloatware removal complete!" -ForegroundColor Green
