#Requires -Version 7.4

[CmdletBinding(SupportsShouldProcess)]
param()

$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

. "$PSScriptRoot/../_scripting/utils.ps1"

Write-Host "Disabling HP bloatware..." -ForegroundColor Green

$config = Get-WinDeveloperConfig
if ($config.bloatware.hp.disable) {
    Stop-AndDisableService "HPAppHelperCap"
    Stop-AndDisableService "HPAudioAnalytics"
    Stop-AndDisableService "HPDiagsCap"
    Stop-AndDisableService "HotKeyServiceUWP"
    Stop-AndDisableService "HpTouchpointAnalyticsService"
    Stop-AndDisableService "LanWlanWwanSwitchingServiceUWP"
    Stop-AndDisableService "HPNetworkCap"
    Stop-AndDisableService "hpsvcsscan"
    Stop-AndDisableService "SFUService"
    Stop-AndDisableService "HPSysInfoCap"
}
