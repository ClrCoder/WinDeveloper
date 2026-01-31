#Requires -Version 7.4

[CmdletBinding(SupportsShouldProcess)]
param()

$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

. "$PSScriptRoot/../_scripting/utils.ps1"

Write-Host "Disabling Intel bloatware..." -ForegroundColor Green

$config = Get-WinDeveloperConfig
if ($config.bloatware.intel.disable) {
    # Uninstall Intel(R) Computing Improvement Program
    $intelCIP = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" | 
        Where-Object { $_.DisplayName -like "*Intel*Computing Improvement Program*" }
    
    if ($intelCIP) {
        Write-Host "Uninstalling Intel(R) Computing Improvement Program..." -ForegroundColor Yellow
        $productCode = $intelCIP.PSChildName
        Start-Process "msiexec.exe" -ArgumentList "/x $productCode /qn /norestart" -Wait -NoNewWindow
        Write-Host "Intel(R) Computing Improvement Program uninstalled." -ForegroundColor Green
    } else {
        Write-Host "Intel(R) Computing Improvement Program not found or already uninstalled." -ForegroundColor Gray
    }

    # Intel Driver & Support Assistant (telemetry/updater)
    Stop-AndDisableService "DSAService" -AllowManualStart
    Stop-AndDisableService "DSAUpdateService" -AllowManualStart
    
    # Intel Dynamic Application Loader (telemetry)
    Stop-AndDisableService "jhi_service"
    
    # Intel Innovation Platform Framework (telemetry)
    Stop-AndDisableService "ipfsvc"
    
    # Intel Dynamic Tuning Technology (telemetry)
    Stop-AndDisableService "dptftcs"

    # Intel Analytics Service (telemetry)
    Stop-AndDisableService "Intel Analytics Service"

    # Intel Connectivity Network Service (telemetry)
    Stop-AndDisableService "Intel Connectivity Network Service"

    # Intel Dynamic Bandwidth Management (telemetry)
    Stop-AndDisableService "IDBWM"

    # Intel Provider Data Helper Service (telemetry)
    Stop-AndDisableService "Intel Provider Data Helper Service"

    # IntelConnect Service (telemetry)
    Stop-AndDisableService "IntelConnectService"
    
    # Intel Management Engine WMI (usually unnecessary)
    Stop-AndDisableService "WMIRegistrationService" -AllowManualStart
    
    # Optional: Uncomment if these services exist on your system
    # Stop-AndDisableService "SystemUsageReportSvc_QUEENCREEK"
    # Stop-AndDisableService "Intel(R) SUR QC SAM"
    # Stop-AndDisableService "ESRV_SVC_QUEENCREEK"

    # Intel Graphics Software Service (set to manual, don't disable completely as it's needed for display)
    Stop-AndDisableService "IntelGraphicsSoftwareService" -AllowManualStart

    # Disable Intel Graphics Software autostart (Settings -> Apps -> Startup)
    # This machine exposes the toggle as a single StartupApproved entry:
    # HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run32\"Intelr Graphics Software"
    $startupApprovedPath = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run32'
    $startupApprovedName = 'Intel® Graphics Software'

    $disabledBytes = [byte[]](0x01, 0x00, 0x00, 0x00, 0xBB, 0xF6, 0x39, 0xE2, 0x29, 0x75, 0xDC, 0x01)
    if ($PSCmdlet.ShouldProcess("$startupApprovedPath\$startupApprovedName", 'Disable startup app')) {
        New-Item -Path $startupApprovedPath -Force | Out-Null
        New-ItemProperty -Path $startupApprovedPath -Name $startupApprovedName -PropertyType Binary -Value $disabledBytes -Force | Out-Null
    }
}

# TODO:
## Manually configure Intel Graphics Software to disable "Allow data collection" in Settings