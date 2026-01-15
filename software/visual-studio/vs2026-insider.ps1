# Install Visual Studio 2026 Community Insider Preview
# Using winget for simple installation

Write-Host "Installing Visual Studio 2026 Community Insider Preview..." -ForegroundColor Cyan

winget install --id Microsoft.VisualStudio.Community.Insiders --accept-source-agreements --accept-package-agreements

Write-Host "Visual Studio 2026 Community Insider Preview installation complete!" -ForegroundColor Green
