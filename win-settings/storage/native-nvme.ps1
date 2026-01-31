#Requires -Version 7.4

[CmdletBinding(SupportsShouldProcess)]
param()

$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

. "$PSScriptRoot/../../_scripting/utils.ps1"

Write-Host "Configuring NVMe Storage Settings..." -ForegroundColor Green

$regPath = "HKLM:\SYSTEM\CurrentControlSet\Policies\Microsoft\FeatureManagement\Overrides"

New-Item -Path $regPath -Force | Out-Null
New-ItemProperty -Path $regPath -Name "1853569164" -Value 1 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $regPath -Name "156965516" -Value 1 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $regPath -Name "735209102" -Value 1 -PropertyType DWord -Force | Out-Null