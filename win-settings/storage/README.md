# Dev Drive

## Dev Drive settings
The DevDrive should be in performance mode.
```PowerShell
# Check current status
Get-MpPreference | Select-Object PerformanceModeStatus

# Enable performance mode for Dev Drives
Set-MpPreference -PerformanceModeStatus Enabled
```