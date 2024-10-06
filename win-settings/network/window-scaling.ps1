#Requires -Version 7.4

[CmdletBinding(SupportsShouldProcess)]
param()

$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

. "$PSScriptRoot/../../_scripting/utils.ps1"

netsh interface tcp set global autotuninglevel=highlyrestricted