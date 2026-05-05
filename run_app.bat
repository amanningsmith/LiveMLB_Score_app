@echo off
REM LiveMLB Score App - Local Launcher
REM This script can be pinned to the taskbar

setlocal enabledelayedexpansion
set APP_DIR=%~dp0
cd /d "%APP_DIR%"

:menu
cls
echo.
echo ========================================
echo   LiveMLB Score App - Local Launcher
echo ========================================
echo.
echo Status:
echo --------

REM Check if Python is installed
python --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [X] Python: NOT FOUND
    echo.
    echo Error: Python is not installed or not in PATH
    echo Please install Python 3.9+ from https://www.python.org
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('python --version') do set PYTHON_VERSION=%%i
echo [OK] Python: %PYTHON_VERSION%

REM Check if venv exists
if exist "venv" (
    echo [OK] Virtual Environment: EXISTS
) else (
    echo [X] Virtual Environment: NOT FOUND
    echo     Run "Create Virtual Environment" first
)

REM Check if flask is installed
venv\Scripts\python -m pip show flask >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [X] Dependencies: NOT INSTALLED
) else (
    echo [OK] Dependencies: INSTALLED
)

REM Check if app.py exists
if exist "app.py" (
    echo [OK] app.py: FOUND
) else (
    echo [X] app.py: NOT FOUND
)

echo.
echo Options:
echo --------
echo 1 - Create/Update Virtual Environment
echo 2 - Install Dependencies
echo 3 - Run App (Flask development server)
echo 4 - Run App with Gunicorn (Production)
echo 5 - Show Logs
echo 6 - Exit
echo.

set /p CHOICE="Enter your choice (1-6): "

if "%CHOICE%"=="1" goto create_venv
if "%CHOICE%"=="2" goto install_deps
if "%CHOICE%"=="3" goto run_dev
if "%CHOICE%"=="4" goto run_prod
if "%CHOICE%"=="5" goto show_logs
if "%CHOICE%"=="6" goto end
goto invalid

:create_venv
cls
echo.
echo Creating virtual environment...
echo.
python -m venv venv
if %ERRORLEVEL% equ 0 (
    echo [OK] Virtual environment created successfully
) else (
    echo [ERROR] Failed to create virtual environment
)
pause
goto menu

:install_deps
cls
echo.
echo Installing dependencies...
echo.
call venv\Scripts\activate.bat
pip install --upgrade pip
pip install -r requirements.txt
if %ERRORLEVEL% equ 0 (
    echo [OK] Dependencies installed successfully
) else (
    echo [ERROR] Failed to install dependencies
)
pause
goto menu

:run_dev
cls
echo.
echo Starting app (Flask development server)...
echo.
echo Access at: http://localhost:5000
echo.
echo Press Ctrl+C to stop the server
echo.
call venv\Scripts\activate.bat
python app.py
pause
goto menu

:run_prod
cls
echo.
echo Starting app with Gunicorn (Production mode)...
echo.
echo Access at: http://localhost:10000
echo.
echo Press Ctrl+C to stop the server
echo.
call venv\Scripts\activate.bat
gunicorn --config gunicorn_config.py app:app
pause
goto menu

:show_logs
cls
echo.
echo Opening logs folder...
echo.
if exist "logs" (
    start "" explorer logs
    timeout /t 2
) else (
    echo [INFO] No logs folder found yet
    pause
)
goto menu

:invalid
cls
echo Invalid choice. Please try again.
pause
goto menu

:end
echo Goodbye!
timeout /t 1
exit /b 0
