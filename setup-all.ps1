#Requires -Version 7.4

[CmdletBinding(SupportsShouldProcess)]
param()

$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

& $PSScriptRoot\win-settings\keyboard.ps1
& $PSScriptRoot\win-settings\network\window-scaling.ps1

& $PSScriptRoot\bloatware\hp.ps1
& $PSScriptRoot\bloatware\intel.ps1
& $PSScriptRoot\bloatware\microsoft.ps1