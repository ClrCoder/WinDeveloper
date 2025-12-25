#Requires -Version 7.4

[CmdletBinding(SupportsShouldProcess)]
param()

$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

.\win-settings\keyboard.ps1
.\win-settings\network\window-scaling.ps1

.\bloatware\hp.ps1
.\bloatware\intel.ps1
.\bloatware\microsoft.ps1