#Requires -Version 7.4

[CmdletBinding(SupportsShouldProcess)]
param()

$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

. "$PSScriptRoot/../../_scripting/utils.ps1"

Write-Host "Configuring fsutil Tweaks..." -ForegroundColor Green

# Disable last access time updates
fsutil behavior set disablelastaccess 1

# Disable 8dot3 filename creation
fsutil 8dot3name set 1
