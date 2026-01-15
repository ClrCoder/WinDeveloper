# Docker Desktop Installation Script
# This script installs Docker Desktop using winget and configures custom data path
# Requires WSL2 to be installed and configured first

. "$PSScriptRoot/../../_scripting/utils.ps1"

# ============================================================================
# Step 1: Check WSL2 is installed
# ============================================================================
Write-Host "Checking WSL2 installation..." -ForegroundColor Cyan

$wslVersion = wsl --version 2>$null
if (-not $wslVersion) {
    Write-Host "ERROR: WSL2 is not installed or not configured properly." -ForegroundColor Red
    Write-Host "Please run the wsl2.ps1 script first." -ForegroundColor Yellow
    return
}

Write-Host "WSL2 is installed - OK" -ForegroundColor Green

# ============================================================================
# Step 2: Install Docker Desktop using winget
# ============================================================================
Write-Host ""
Write-Host "Installing Docker Desktop..." -ForegroundColor Cyan

$dockerInstalled = winget list --id Docker.DockerDesktop --exact 2>$null
if ($dockerInstalled -match "Docker.DockerDesktop") {
    Write-Host "Docker Desktop is already installed - OK" -ForegroundColor Green
}
else {
    Write-Host "Installing Docker Desktop via winget..." -ForegroundColor Yellow
    winget install --id Docker.DockerDesktop --exact --silent --accept-package-agreements --accept-source-agreements
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Docker Desktop installed successfully" -ForegroundColor Green
    }
    else {
        Write-Host "ERROR: Failed to install Docker Desktop" -ForegroundColor Red
        return
    }
}

# ============================================================================
# Step 3: Configure custom storage path
# ============================================================================
$config = Get-WinDeveloperConfig
$storagePath = $config.software?.dockerDesktop?.storagePath

if ($storagePath) {
    Write-Host ""
    Write-Host "Custom storage path configured: $storagePath" -ForegroundColor Cyan
    
    # Ensure the storage directory exists
    if (-not (Test-Path $storagePath)) {
        Write-Host "Creating storage directory: $storagePath" -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $storagePath -Force | Out-Null
    }
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "MANUAL CONFIGURATION REQUIRED" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "Please change the Docker Desktop data path manually:" -ForegroundColor Yellow
    Write-Host "1. Open Docker Desktop" -ForegroundColor White
    Write-Host "2. Go to Settings -> Resources -> Advanced" -ForegroundColor White
    Write-Host "3. Set 'Disk image location' to: $storagePath" -ForegroundColor White
    Write-Host "4. Click 'Apply & Restart'" -ForegroundColor White
    Write-Host "========================================" -ForegroundColor Yellow
}
else {
    Write-Host ""
    Write-Host "No custom storage path configured. Using default Docker Desktop location." -ForegroundColor Gray
}

# ============================================================================
# Step 4: Final status
# ============================================================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Docker Desktop setup complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

