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
    Write-Verbose "$($fileDetails.LastWriteTimeUtc)"
    if ($fileDetails.LastWriteTimeUtc -ne $script:WinDeveloperConfigLastWriteTime) {
        Write-Verbose "Reading WinDeveloper config file."
        $script:WinDeveloperConfigLastWriteTime = $fileDetails.LastWriteTimeUtc
        # Here is the extension point to avoid multiple fetch of the file if it wasn't changed.
        $script:WinDeveloperConfig = Get-Content -Path "$PSScriptRoot/../config.json" | ConvertFrom-Json -AsHashtable -Depth 10
        
        Write-Verbose ($script:WinDeveloperConfig | ConvertTo-Json -Depth 10)
    }
    
    return $script:WinDeveloperConfig
}
