#Requires -Version 7.4

[CmdletBinding(SupportsShouldProcess)]
param()

$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

. "$PSScriptRoot/../_scripting/utils.ps1"

function Get-KeyboardRepeatDelay {
    [uint]$delay = 0
    $result = [ClrCoder.WinDeveloper.Win32]::SystemParametersInfo(
        0x0016, # SPI_GETKEYBOARDDELAY
        0,
        [ref]$delay,
        0
    )

    if ($result) {
        return $delay
    }
    else {
        throw "Failed to retrieve the keyboard delay."
    }
}

function Set-KeyboardRepeatDelay {
    param(
        [int]$Delay
    )

    $result = [ClrCoder.WinDeveloper.Win32]::SystemParametersInfoNoRef(
        0x0017, # SPI_SETKEYBOARDDELAY
        $Delay,
        0
    )

    if ($result) {
        Write-Verbose "KeyboardDelay successfully set to $Delay"
    }
    else {
        throw "Failed to set the keyboard delay."
    }
}

Write-Host "Updating keyboard settings..." -ForegroundColor Green

Write-Verbose (Get-KeyboardRepeatDelay)
$config = Get-WinDeveloperConfig
$repeatDelayToSet = $config.winSettings.keyboard.standardRepeatDelay
if ($null -ne $repeatDelayToSet) {
    $repeatDelayToSetInt = [int]$repeatDelayToSet
    $currentRepeatDelay = Get-KeyboardRepeatDelay
    if ($repeatDelayToSetInt -ne $currentRepeatDelay) {
        Write-Host "  Updating standard keyboard repeat delay from $currentRepeatDelay to $repeatDelayToSetInt"
        Set-KeyboardRepeatDelay $repeatDelayToSetInt
    }
}
