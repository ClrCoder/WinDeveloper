#Requires -Version 7.4

[CmdletBinding(SupportsShouldProcess)]
param()

$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

. "$PSScriptRoot/../../_scripting/utils.ps1"

Write-Host "Configuring Windows TCP Window Scaling..." -ForegroundColor Green
netsh interface tcp set global autotuninglevel=highlyrestricted