# LiveMLB Score App - PowerShell Launcher
# More powerful alternative to run_app.bat

param(
    [string]$Mode = "menu",
    [switch]$Dev = $false,
    [switch]$Prod = $false
)

$AppDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $AppDir

function Show-Status {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  LiveMLB Score App - Status" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    # Check Python
    try {
        $pythonVersion = & python --version 2>&1
        Write-Host "✓ Python: $pythonVersion" -ForegroundColor Green
    } catch {
        Write-Host "✗ Python: NOT FOUND" -ForegroundColor Red
    }
    
    # Check venv
    if (Test-Path ".\venv") {
        Write-Host "✓ Virtual Environment: EXISTS" -ForegroundColor Green
    } else {
        Write-Host "✗ Virtual Environment: NOT FOUND" -ForegroundColor Yellow
    }
    
    # Check dependencies
    try {
        & .\venv\Scripts\python -m pip show flask > $null 2>&1
        if ($?) {
            Write-Host "✓ Dependencies: INSTALLED" -ForegroundColor Green
        } else {
            Write-Host "✗ Dependencies: NOT INSTALLED" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "✗ Dependencies: NOT INSTALLED" -ForegroundColor Yellow
    }
    
    # Check app.py
    if (Test-Path ".\app.py") {
        Write-Host "✓ app.py: FOUND" -ForegroundColor Green
    } else {
        Write-Host "✗ app.py: NOT FOUND" -ForegroundColor Red
    }
    
    # Check logs
    if (Test-Path ".\logs") {
        $logCount = @(Get-ChildItem .\logs 2>/dev/null).Count
        Write-Host "✓ Logs: $logCount file(s)" -ForegroundColor Green
    } else {
        Write-Host "○ Logs: Not created yet" -ForegroundColor Gray
    }
    
    Write-Host "`n"
}

function Show-Menu {
    Write-Host "Options:" -ForegroundColor Cyan
    Write-Host "--------" -ForegroundColor Cyan
    Write-Host "1 - Create/Update Virtual Environment"
    Write-Host "2 - Install Dependencies"
    Write-Host "3 - Run App (Flask dev server)"
    Write-Host "4 - Run App (Gunicorn production)"
    Write-Host "5 - Show Logs"
    Write-Host "6 - Open Project Folder"
    Write-Host "7 - Exit"
    Write-Host ""
}

function Create-VirtualEnv {
    Write-Host "`nCreating virtual environment..." -ForegroundColor Yellow
    & python -m venv venv
    if ($?) {
        Write-Host "✓ Virtual environment created successfully" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to create virtual environment" -ForegroundColor Red
    }
    Read-Host "`nPress Enter to continue"
}

function Install-Dependencies {
    Write-Host "`nInstalling dependencies..." -ForegroundColor Yellow
    & .\venv\Scripts\activate.ps1
    & pip install --upgrade pip
    & pip install -r requirements.txt
    if ($?) {
        Write-Host "`n✓ Dependencies installed successfully" -ForegroundColor Green
    } else {
        Write-Host "`n✗ Failed to install dependencies" -ForegroundColor Red
    }
    Read-Host "Press Enter to continue"
}

function Run-Dev {
    Write-Host "`nStarting Flask development server..." -ForegroundColor Yellow
    Write-Host "Access at: http://localhost:5000" -ForegroundColor Cyan
    Write-Host "Logs will appear below. Press Ctrl+C to stop.`n" -ForegroundColor Gray
    
    & .\venv\Scripts\activate.ps1
    & python app.py
}

function Run-Prod {
    Write-Host "`nStarting Gunicorn (production mode)..." -ForegroundColor Yellow
    Write-Host "Access at: http://localhost:10000" -ForegroundColor Cyan
    Write-Host "Logs will appear below. Press Ctrl+C to stop.`n" -ForegroundColor Gray
    
    & .\venv\Scripts\activate.ps1
    & gunicorn --config gunicorn_config.py app:app
}

function Show-Logs {
    if (Test-Path ".\logs") {
        Write-Host "`nOpening logs folder..." -ForegroundColor Yellow
        Start-Process explorer.exe ".\logs"
    } else {
        Write-Host "`nNo logs folder found yet" -ForegroundColor Yellow
    }
}

# Main menu loop
do {
    Clear-Host
    Show-Status
    Show-Menu
    
    $choice = Read-Host "Enter your choice (1-7)"
    
    switch ($choice) {
        "1" { Create-VirtualEnv }
        "2" { Install-Dependencies }
        "3" { Run-Dev }
        "4" { Run-Prod }
        "5" { Show-Logs }
        "6" { Start-Process explorer.exe "." }
        "7" { exit }
        default {
            Write-Host "Invalid choice. Please try again." -ForegroundColor Red
            Read-Host "Press Enter to continue"
        }
    }
} while ($true)
