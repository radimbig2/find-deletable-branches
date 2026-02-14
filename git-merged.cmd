@echo off
setlocal enabledelayedexpansion

REM Get current directory
set CURRENT_DIR=%CD%

REM Try to find Git Bash using git.exe location
for /f "tokens=*" %%i in ('where git.exe 2^>nul') do (
    set GIT_PATH=%%i
    goto :found_git
)
goto :try_common

:found_git
REM Extract directory and construct path to bash.exe
for %%i in ("%GIT_PATH%") do set GIT_DIR=%%~dpi
set BASH_EXE=%GIT_DIR%bash.exe
if exist "%BASH_EXE%" (
    cd /d "%CURRENT_DIR%"
    "%BASH_EXE%" "%~dp0git-merged" %*
    exit /b %ERRORLEVEL%
)

REM Try alternative path (bin folder)
set BASH_EXE=%GIT_DIR%..\bin\bash.exe
if exist "%BASH_EXE%" (
    "%BASH_EXE%" "%~dp0git-merged" %*
    exit /b %ERRORLEVEL%
)

:try_common
REM Try Git Bash in Program Files
if exist "C:\Program Files\Git\bin\bash.exe" (
    "C:\Program Files\Git\bin\bash.exe" "%~dp0git-merged" %*
    exit /b %ERRORLEVEL%
)

REM Try Git Bash in Program Files (x86)
if exist "C:\Program Files (x86)\Git\bin\bash.exe" (
    "C:\Program Files (x86)\Git\bin\bash.exe" "%~dp0git-merged" %*
    exit /b %ERRORLEVEL%
)

REM Try Git for Windows default location
if exist "%ProgramFiles%\Git\bin\bash.exe" (
    "%ProgramFiles%\Git\bin\bash.exe" "%~dp0git-merged" %*
    exit /b %ERRORLEVEL%
)

REM Error - bash not found
echo Error: Git Bash not found. Please install Git for Windows from https://git-scm.com/download/win
exit /b 1
