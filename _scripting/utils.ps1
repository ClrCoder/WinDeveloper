if (-not (([System.Management.Automation.PSTypeName]"ClrCoder.WinDeveloper.Win32").Type)) {
    Write-Verbose "Adding types for the WinDeveloper scripting utils."
    Add-Type @"
using System;
using System.Runtime.InteropServices;
namespace ClrCoder.WinDeveloper;
public class Win32 {
    [DllImport("user32.dll", CharSet=CharSet.Auto)]
    public static extern bool SystemParametersInfo(
        uint uiAction,
        uint uiParam,
        out uint pvParam,
        uint fWinIni);

    [DllImport("user32.dll", CharSet=CharSet.Auto, EntryPoint="SystemParametersInfo")]
    public static extern bool SystemParametersInfoNoRef(
        uint uiAction,
        uint uiParam,
        IntPtr zero,
        uint fWinIni);

    [DllImport("user32.dll", CharSet=CharSet.Auto, EntryPoint="SystemParametersInfo")]
    public static extern bool SystemParametersInfoFilterKeys(
        uint uiAction,
        uint uiParam,
        ref FILTERKEYS pvParam,
        uint fWinIni);
}

[StructLayout(LayoutKind.Sequential)]
public struct FILTERKEYS {
  public uint cbSize;
  public uint dwFlags;
  public uint iWaitMSec;
  public uint iDelayMSec;
  public uint iRepeatMSec;
  public uint iBounceMSec;
}
"@
}

function Get-WinDeveloperConfig {
    $configFilePath = Resolve-Path "$PSScriptRoot/../config.json"
    $fileDetails = Get-ChildItem -Path $configFilePath
    if ($fileDetails.LastWriteTimeUtc -ne $global:__WinDeveloper__ConfigLastWriteTime) {
        Write-Verbose "Reading WinDeveloper config file."
        $global:__WinDeveloper__ConfigLastWriteTime = $fileDetails.LastWriteTimeUtc
        # Here is the extension point to avoid multiple fetch of the file if it wasn't changed.
        $global:__WinDeveloper__Config = Get-Content -Path "$PSScriptRoot/../config.json" | ConvertFrom-Json -AsHashtable -Depth 10
        
        Write-Verbose ($global:__WinDeveloper__Config | ConvertTo-Json -Depth 10)
    }
    
    return $global:__WinDeveloper__Config
}

function Stop-AndDisableService {
    param(
        [string]$ServiceName,
        [switch]$AllowManualStart

    )

    $svc = Get-Service $ServiceName -ErrorAction SilentlyContinue   
    if ($null -eq $svc) {
        Write-Verbose "Service $ServiceName not found"
        return
    }
    if ($svc.Status -eq "Running") {
        Write-Verbose "Stopping service $ServiceName"
        Stop-Service $ServiceName
    }
    if ($AllowManualStart) {
        if ($svc.StartType -ne "Manual") {
            Write-Verbose "Making service $ServiceName to be started manually"
            Set-Service $ServiceName -StartupType Manual
        }
    }
    else {
        if ($svc.StartType -ne "Disabled") {
            Write-Verbose "Disabling service $ServiceName"
            Set-Service $ServiceName -StartupType Disabled
        }
    }
}
