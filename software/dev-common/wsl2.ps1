# WSL2 Installation Script
# This script installs and configures WSL2 with a custom data path for VHDX storage
# Uses sudo for inline elevation (requires Win11 24H2+ with sudo configured)

. "$PSScriptRoot/../../_scripting/utils.ps1"

# ============================================================================
# Step 1: Check and Enable Windows Features (using sudo for elevation)
# ============================================================================
$featuresNeeded = @(
    "Microsoft-Windows-Subsystem-Linux",
    "VirtualMachinePlatform"
)

$rebootRequired = $false

foreach ($feature in $featuresNeeded) {
    $featureState = sudo pwsh -Command "(Get-WindowsOptionalFeature -Online -FeatureName '$feature').State"
    
    if ($featureState -eq "Enabled") {
        Write-Host "Feature '$feature' is already enabled - OK" -ForegroundColor Green
    }
    else {
        Write-Host "Enabling feature '$feature'..." -ForegroundColor Yellow
        $resultJson = sudo pwsh -Command "Enable-WindowsOptionalFeature -Online -FeatureName '$feature' -NoRestart | ConvertTo-Json"
        $result = $resultJson | ConvertFrom-Json
        if ($result.RestartNeeded) {
            $rebootRequired = $true
        }
        Write-Host "Feature '$feature' enabled successfully" -ForegroundColor Green
    }
}

# ============================================================================
# Step 2: Report status and check for reboot
# ============================================================================
if ($rebootRequired) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "REBOOT REQUIRED" -ForegroundColor Yellow
    Write-Host "Please restart your computer and run this script again." -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    return
}

Write-Host ""
Write-Host "All Windows features are enabled!" -ForegroundColor Green

# ============================================================================
# Step 3: Configure custom storage path for WSL2
# ============================================================================
$config = Get-WinDeveloperConfig
$storagePath = $config.software?.wsl2?.storagePath

if ($storagePath) {
    Write-Host ""
    Write-Host "Configuring custom WSL2 storage path: $storagePath" -ForegroundColor Cyan
    
    # Ensure the storage directory exists
    if (-not (Test-Path $storagePath)) {
        Write-Host "Creating storage directory: $storagePath" -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $storagePath -Force | Out-Null
    }
    
    # Configure .wslconfig for custom storage path
    $wslConfigPath = "$env:USERPROFILE\.wslconfig"
    $wslConfigContent = @"
[wsl2]
# Custom storage path for WSL2 distributions
# Note: New distributions will be installed to this path

[experimental]
autoMemoryReclaim=gradual
"@
    
    if (Test-Path $wslConfigPath) {
        Write-Host "Existing .wslconfig found at $wslConfigPath" -ForegroundColor Yellow
    }
    else {
        Set-Content -Path $wslConfigPath -Value $wslConfigContent
        Write-Host "Created .wslconfig at $wslConfigPath" -ForegroundColor Green
    }
    
    # Install Ubuntu to the custom storage path
    Write-Host ""
    Write-Host "Installing Ubuntu to custom path..." -ForegroundColor Cyan
    wsl --install -d Ubuntu --location "$storagePath\Ubuntu"
}
else {
    Write-Host "No custom storage path configured. Using default WSL2 storage location." -ForegroundColor Gray
}

# ============================================================================
# Step 4: Final status
# ============================================================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "WSL2 setup complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
