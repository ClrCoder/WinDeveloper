
#Requires -Version 7.4

[CmdletBinding(SupportsShouldProcess)]
param()

$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

. "$PSScriptRoot/../_scripting/utils.ps1"

function Test-IsAdmin {
	return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
		[Security.Principal.WindowsBuiltInRole]::Administrator
	)
}

function Set-RegistryDword {
	param(
		[Parameter(Mandatory)]
		[string]$Path,

		[Parameter(Mandatory)]
		[string]$Name,

		[Parameter(Mandatory)]
		[int]$Value
	)

	if ($PSCmdlet.ShouldProcess("$Path\\$Name", "Set DWORD=$Value")) {
		New-Item -Path $Path -Force | Out-Null
		New-ItemProperty -Path $Path -Name $Name -PropertyType DWord -Value $Value -Force | Out-Null
	}
}

function Disable-ScheduledTasksSafe {
	param(
		[Parameter(Mandatory)]
		[string[]]$TaskPaths
	)

	foreach ($taskPath in $TaskPaths) {
		$tasks = Get-ScheduledTask -TaskPath $taskPath -ErrorAction SilentlyContinue
		if (-not $tasks) {
			continue
		}

		foreach ($task in $tasks) {
			if ($task.State -ne 'Disabled') {
				if ($PSCmdlet.ShouldProcess("$($task.TaskPath)$($task.TaskName)", 'Disable scheduled task')) {
					Disable-ScheduledTask -TaskName $task.TaskName -TaskPath $task.TaskPath | Out-Null
				}
			}
		}
	}
}

function Stop-ProcessesSafe {
	param(
		[Parameter(Mandatory)]
		[string[]]$Names
	)

	foreach ($name in $Names) {
		$procs = Get-Process -Name $name -ErrorAction SilentlyContinue
		if (-not $procs) {
			continue
		}

		foreach ($proc in $procs) {
			if ($PSCmdlet.ShouldProcess("$($proc.ProcessName) ($($proc.Id))", 'Stop process')) {
				Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
			}
		}
	}
}

Write-Host 'Disabling Windows Search components and Start-menu web search...' -ForegroundColor Green

$config = Get-WinDeveloperConfig
$disable = $true
if ($null -ne $config.bloatware.windowsSearch.disable) {
	$disable = [bool]$config.bloatware.windowsSearch.disable
}

if (-not $disable) {
	Write-Host '  Skipped (config.bloatware.windowsSearch.disable is false)' -ForegroundColor Gray
	return
}

$isAdmin = Test-IsAdmin
if (-not $isAdmin) {
	Write-Host '⚠ Not running as Administrator - will only apply current-user web-search policies.' -ForegroundColor Yellow
	Write-Host '  Run PowerShell as Administrator to disable the Windows Search service and machine policies.' -ForegroundColor Yellow
}

# 1) Disable Start-menu web search / Bing suggestions
# Win11/Win10 policy keys that reduce/disable web search and suggestions.
Set-RegistryDword -Path 'HKCU:\Software\Policies\Microsoft\Windows\Explorer' -Name 'DisableSearchBoxSuggestions' -Value 1

# Legacy / compatibility keys (still honored on some builds)
Set-RegistryDword -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'BingSearchEnabled' -Value 0
Set-RegistryDword -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'CortanaConsent' -Value 0

# Disable Search Highlights / dynamic box content where present
Set-RegistryDword -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings' -Name 'IsDynamicSearchBoxEnabled' -Value 0

if ($isAdmin) {
	# Machine-wide policy equivalents
	Set-RegistryDword -Path 'HKLM:\Software\Policies\Microsoft\Windows\Explorer' -Name 'DisableSearchBoxSuggestions' -Value 1

	# Windows Search policies
	Set-RegistryDword -Path 'HKLM:\Software\Policies\Microsoft\Windows\Windows Search' -Name 'DisableWebSearch' -Value 1
	Set-RegistryDword -Path 'HKLM:\Software\Policies\Microsoft\Windows\Windows Search' -Name 'ConnectedSearchUseWeb' -Value 0
	Set-RegistryDword -Path 'HKLM:\Software\Policies\Microsoft\Windows\Windows Search' -Name 'ConnectedSearchUseWebOverMeteredConnections' -Value 0
	Set-RegistryDword -Path 'HKLM:\Software\Policies\Microsoft\Windows\Windows Search' -Name 'AllowCloudSearch' -Value 0
}

# 2) Disable Windows Search components (indexer service + scheduled tasks + running UI processes)
Stop-ProcessesSafe -Names @(
	'SearchHost',
	'SearchApp',
	'SearchUI',
	'SearchIndexer'
)

if ($isAdmin) {
	Stop-AndDisableService 'WSearch'

	Disable-ScheduledTasksSafe -TaskPaths @(
		'\\Microsoft\\Windows\\Search\\',
		'\\Microsoft\\Windows\\Windows Search\\'
	)
}

# Run PowerShell as Administrator

$regPath = "HKLM:\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\8\1694661260"

# Create the registry key if it doesn't exist
New-Item -Path $regPath -Force | Out-Null

# Set the DWORD values
New-ItemProperty -Path $regPath -Name "EnabledState"        -Value 1 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $regPath -Name "EnabledStateOptions" -Value 0 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $regPath -Name "Variant"             -Value 0 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $regPath -Name "VariantPayload"      -Value 0 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $regPath -Name "VariantPayloadKind"  -Value 0 -PropertyType DWord -Force | Out-Null


Write-Host '  Done. A sign-out/restart may be required for all changes to take effect.' -ForegroundColor Green
