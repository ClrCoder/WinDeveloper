#Requires -Version 7.4

[CmdletBinding(SupportsShouldProcess)]
param()

$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

. "$PSScriptRoot/../_scripting/utils.ps1"

Write-Host "Disabling Intel bloatware..." -ForegroundColor Green

$config = Get-WinDeveloperConfig
if ($config.bloatware.intel.disable) {
    Stop-AndDisableService "DSAService" -AllowManualStart
    Stop-AndDisableService "DSAUpdateService" -AllowManualStart
    Stop-AndDisableService "jhi_service"
    Stop-AndDisableService "ipfsvc"
    Stop-AndDisableService "dptftcs"
    Stop-AndDisableService "SystemUsageReportSvc_QUEENCREEK"
    Stop-AndDisableService "Intel(R) SUR QC SAM"
    Stop-AndDisableService "ESRV_SVC_QUEENCREEK"
}
