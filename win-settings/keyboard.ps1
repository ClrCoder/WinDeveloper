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
        [IntPtr]::Zero,
        3 # SPIF_UPDATEINIFILE | SPIF_SENDCHANGE
    )

    if ($result) {
        Write-Verbose "KeyboardDelay successfully set to $Delay"
    }
    else {
        throw "Failed to set the keyboard delay."
    }
}

function Get-KeyboardSpeed {

    [uint]$repeatRate = 0
    $result = [ClrCoder.WinDeveloper.Win32]::SystemParametersInfo(
        0x000A, # SPI_GETKEYBOARDSPEED
        0,
        [ref]$repeatRate,
        0
    )

    if ($result) {
        return $repeatRate
    }
    else {
        throw "Failed to retrieve the keyboard repeat rate."
    }
}

function Set-KeyboardSpeed {
    param(
        [int]$RepeatRate
    )

    $result = [ClrCoder.WinDeveloper.Win32]::SystemParametersInfoNoRef(
        0x000B, # SPI_SETKEYBOARDSPEED
        $RepeatRate,
        [IntPtr]::Zero,
        3 # SPIF_UPDATEINIFILE | SPIF_SENDCHANGE
    )

    if ($result) {
        Write-Verbose "Keyboard Speed successfully set to $RepeatRate"
    }
    else {
        throw "Failed to set the keyboard speed."
    }
}

function Get-FilterKeysSettings {
    $filterKeys = [ClrCoder.WinDeveloper.FILTERKEYS]::new()
    $filterKeys.cbSize = [uint][System.Runtime.InteropServices.Marshal]::SizeOf($filterKeys)
    $result = [ClrCoder.WinDeveloper.Win32]::SystemParametersInfoFilterKeys(
        0x0032, # SPI_GETFILTERKEYS
        0,
        [ref]$filterKeys,
        0
    )

    if ($result) {
        return @{
            IsEnabled      = ($filterKeys.dwFlags -band 0x01) -ne 0 # FKF_FILTERKEYSON
            Delay          = $filterKeys.iDelayMSec
            RepeatInterval = $filterKeys.iRepeatMSec
        }
    }
    else {
        throw "Failed to retrieve the filterkey settings"
    }
}

function Set-FilterKeysSettings {
    param(
        [bool]$IsEnabled,
        [int]$Delay,
        [int]$RepeatInterval
    )
    
    $filterKeys = [ClrCoder.WinDeveloper.FILTERKEYS]::new()
    $filterKeys.cbSize = [uint][System.Runtime.InteropServices.Marshal]::SizeOf($filterKeys)
    $result = [ClrCoder.WinDeveloper.Win32]::SystemParametersInfoFilterKeys(
        0x0032, # SPI_GETFILTERKEYS
        0,
        [ref]$filterKeys,
        3 # SPIF_UPDATEINIFILE | SPIF_SENDCHANGE
    )

    if (!$result) {
        throw "Failed to retrieve the filterkey settings"
    }

    $isCurrentlyEnabled = ($filterKeys.dwFlags -band 0x01) -ne 0 # FKF_FILTERKEYSON

    if ($IsEnabled -ne $isCurrentlyEnabled) {
        if ($IsEnabled) {
            $filterKeys.dwFlags = $filterKeys.dwFlags -bor 0x01 # FKF_FILTERKEYSON
        }
        else {
            $filterKeys.dwFlags = $filterKeys.dwFlags -band (-bnot 0x01) # FKF_FILTERKEYSON
        }
    }

    $filterKeys.iWaitMSec = 0
    $filterKeys.iDelayMSec = $Delay
    $filterKeys.iRepeatMSec = $RepeatInterval
    
    $result = [ClrCoder.WinDeveloper.Win32]::SystemParametersInfoFilterKeys(
        0x0033, # SPI_SETFILTERKEYS
        0,
        [ref]$filterKeys,
        0
    )

    if ($result) {
        Write-Verbose "Updated FilterKeys settings: $($filterKeys | ConvertTo-Json)"
    }
    else {
        throw "Failed to set the filterkey settings"
    }
}

Write-Host "Updating keyboard settings..." -ForegroundColor Green

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


if ($null -ne $config.winSettings.keyboard.filterKeys.enabled) {
    
    $filterKeySettings = Get-FilterKeysSettings
    
    $filterKeyChangeNeeded = $false
    
    if ($filterKeySettings.IsEnabled -ne $config.winSettings.keyboard.filterKeys.enabled) {
        $filterKeyChangeNeeded = $true
        Write-Host "  Updating FilterKeys enabled from $($filterKeySettings.IsEnabled) to $($config.winSettings.keyboard.filterKeys.enabled)"
    }
    
    $repeatDelayToSet = $config.winSettings.keyboard.filterKeys.repeatDelay
    $repeatIntervalToSet = $config.winSettings.keyboard.filterKeys.repeatInterval
    if ($filterKeySettings.IsEnabled -and ($filterKeySettings.Delay -ne $repeatDelayToSet)) {
        $filterKeyChangeNeeded = $true
        Write-Host "  Updating FilterKeys delay from $($filterKeySettings.Delay) to $repeatDelayToSet"
    }

    if ($filterKeySettings.IsEnabled -and ($filterKeySettings.RepeatInterval -ne $repeatIntervalToSet)) {
        $filterKeyChangeNeeded = $true
        Write-Host "  Updating FilterKeys repeat interval from $($filterKeySettings.RepeatInterval) to $repeatIntervalToSet"
    }
    
    if ($filterKeyChangeNeeded) {
        Set-FilterKeysSettings `
            -IsEnabled $config.winSettings.keyboard.filterKeys.enabled `
            -Delay $repeatDelayToSet `
            -RepeatInterval $repeatIntervalToSet
    }
}



