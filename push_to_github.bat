@echo off
echo ==============================================================================
echo Pushing NYC Road Safety Visual Analytics Project to GitHub
echo Remote: https://github.com/Monasree005/NYC_Road_Safety_Visual_Analytics.git
echo ==============================================================================
cd /d "C:\Users\nivet\Documents\NYC_Road_Safety_Visual_Analytics"
git push -u origin main
if %ERRORLEVEL% equ 0 (
    echo.
    echo ==============================================================================
    echo SUCCESS: Project successfully pushed to GitHub!
    echo View repository at: https://github.com/Monasree005/NYC_Road_Safety_Visual_Analytics
    echo ==============================================================================
) else (
    echo.
    echo ==============================================================================
    echo NOTE: If you got 'Repository not found', please ensure:
    echo 1. You created the repository on https://github.com/new
    echo    Repository name: NYC_Road_Safety_Visual_Analytics
    echo    Visibility: Public
    echo    Leave all initialization boxes (README, .gitignore) UNCHECKED!
    echo 2. You are logged into your GitHub account (Monasree005) when prompted.
    echo ==============================================================================
)
pause
