Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "Pushing NYC Road Safety Visual Analytics Project to GitHub" -ForegroundColor Cyan
Write-Host "Remote: https://github.com/Monasree005/NYC_Road_Safety_Visual_Analytics.git" -ForegroundColor Gray
Write-Host "==============================================================================" -ForegroundColor Cyan

Set-Location "C:\Users\nivet\Documents\NYC_Road_Safety_Visual_Analytics"
git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nSUCCESS: Project successfully pushed to GitHub!" -ForegroundColor Green
    Write-Host "View repository at: https://github.com/Monasree005/NYC_Road_Safety_Visual_Analytics" -ForegroundColor Green
} else {
    Write-Host "`nNOTE: If you got 'Repository not found', please make sure:" -ForegroundColor Yellow
    Write-Host "1. You created the repository at https://github.com/new" -ForegroundColor Yellow
    Write-Host "   Repository name: NYC_Road_Safety_Visual_Analytics" -ForegroundColor White
    Write-Host "   Visibility: Public" -ForegroundColor White
    Write-Host "   Leave 'Add README', '.gitignore', 'license' UNCHECKED!" -ForegroundColor White
    Write-Host "2. You are logged into GitHub as 'Monasree005' when prompted by Git Credential Manager." -ForegroundColor Yellow
}
