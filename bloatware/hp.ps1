#Requires -Version 7.4

[CmdletBinding(SupportsShouldProcess)]
param()

$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

. "$PSScriptRoot/../_scripting/utils.ps1"

Write-Host "Disabling HP bloatware..." -ForegroundColor Green

$config = Get-WinDeveloperConfig
if ($config.bloatware.hp.disable) {
    # HP Application and Helper Services
    Stop-AndDisableService "HPAppHelperCap"           # HP App Helper HSA Service
    
    # HP Analytics and Telemetry Services
    Stop-AndDisableService "HPAudioAnalytics"         # HP Audio Analytics Service
    Stop-AndDisableService "HpTouchpointAnalyticsService"  # HP Insights Analytics
    Stop-AndDisableService "hpsvcsscan"               # HP Services Scan
    
    # HP Diagnostics and System Info
    Stop-AndDisableService "HPDiagsCap"               # HP Diagnostics HSA Service
    Stop-AndDisableService "HPSysInfoCap"             # HP System Info HSA Service
    
    # HP Hardware/Network Services
    Stop-AndDisableService "HotKeyServiceUWP"         # HP Hotkey UWP Service
    Stop-AndDisableService "LanWlanWwanSwitchingServiceUWP"  # HP LAN/WLAN/WWAN Switching UWP Service
    Stop-AndDisableService "HPNetworkCap"             # HP Network HSA Service
    
    # HP Software Update and Framework
    Stop-AndDisableService "SFUService"               # HP SFU Service
}
