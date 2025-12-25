# Install Git + TortoiseGit

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
	throw "winget not found. Install 'App Installer' from Microsoft Store (or install winget) and re-run."
}

winget install --id Git.Git --source winget -e --accept-source-agreements --accept-package-agreements
winget install --id TortoiseGit.TortoiseGit --source winget -e --accept-source-agreements --accept-package-agreements

