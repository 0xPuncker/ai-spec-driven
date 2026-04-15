@echo off
REM Spec-Driven Development Skill Setup Script for Windows
REM Compatible with: Windows 10/11 with Command Prompt

setlocal enabledelayedexpansion

REM Plugin metadata
set PLUGIN_NAME=spec-driven-dev
set PLUGIN_VERSION=1.0.0
set MARKETPLACE=local

echo ==========================================================
echo   Spec-Driven Development Skill Setup Script
echo ==========================================================
echo.
echo Detected OS: Windows
echo.

REM Detect Claude Code directory
echo [INFO] Detecting Claude Code installation...

set CLAUDE_DIR=
set APPDATA_CLAUDE=%APPDATA%\Claude
set USERPROFILE_CLAUDE=%USERPROFILE%\.claude

if exist "%APPDATA_CLAUDE%" (
    set CLAUDE_DIR=%APPDATA_CLAUDE%
    echo [SUCCESS] Found Claude Code at: %CLAUDE_DIR%
) else if exist "%USERPROFILE_CLAUDE%" (
    set CLAUDE_DIR=%USERPROFILE_CLAUDE%
    echo [SUCCESS] Found Claude Code at: %CLAUDE_DIR%
) else (
    echo [ERROR] Could not find Claude Code installation directory
    echo.
    echo Claude Code may not be installed. Please install it from:
    echo https://claude.ai/code
    echo.
    echo For manual installation, see:
    echo https://github.com/0xPuncker/ai-spec-driven/blob/main/INSTALL.md
    pause
    exit /b 1
)

REM Get repository root (script is in scripts/ subdirectory, so go up one level)
set REPO_ROOT=%~dp0..
echo [INFO] Repository root: %REPO_ROOT%

REM Create plugin structure
set CACHE_DIR=%CLAUDE_DIR%\plugins\cache\%MARKETPLACE%\%PLUGIN_NAME%\%PLUGIN_VERSION%
echo [INFO] Creating plugin directory structure...

if not exist "%CACHE_DIR%\.claude-plugin" mkdir "%CACHE_DIR%\.claude-plugin"
if not exist "%CACHE_DIR%\agents" mkdir "%CACHE_DIR%\agents"
if not exist "%CACHE_DIR%\references" mkdir "%CACHE_DIR%\references"
if not exist "%CACHE_DIR%\templates" mkdir "%CACHE_DIR%\templates"

echo [SUCCESS] Created plugin directory: %CACHE_DIR%

REM Copy files
echo [INFO] Copying plugin files...

if exist "%REPO_ROOT%\.claude-plugin\plugin.json" (
    copy /Y "%REPO_ROOT%\.claude-plugin\plugin.json" "%CACHE_DIR%\.claude-plugin\" >/dev/null
    echo [SUCCESS] Copied plugin metadata
) else (
    echo [ERROR] plugin.json not found in repository
    pause
    exit /b 1
)

if exist "%REPO_ROOT%\SKILL.md" (
    copy /Y "%REPO_ROOT%\SKILL.md" "%CACHE_DIR%\agents\" >/dev/null
    echo [SUCCESS] Copied main skill file
) else (
    echo [ERROR] SKILL.md not found in repository
    pause
    exit /b 1
)

if exist "%REPO_ROOT%\references" (
    xcopy /E /I /Y "%REPO_ROOT%\references\*" "%CACHE_DIR%\references\" >/dev/null
    echo [SUCCESS] Copied reference guides
)

if exist "%REPO_ROOT%\templates" (
    xcopy /E /I /Y "%REPO_ROOT%\templates\*" "%CACHE_DIR%\templates\" >/dev/null
    echo [SUCCESS] Copied templates
)

if exist "%REPO_ROOT%\CLAUDE.md" (
    copy /Y "%REPO_ROOT%\CLAUDE.md" "%CACHE_DIR%\" >/dev/null
    echo [SUCCESS] Copied CLAUDE.md
)

REM Verify installation
echo.
echo [INFO] Verifying installation...

set MISSING_FILES=0

if not exist "%CACHE_DIR%\.claude-plugin\plugin.json" set MISSING_FILES=1
if not exist "%CACHE_DIR%\agents\SKILL.md" set MISSING_FILES=1
if not exist "%CACHE_DIR%\references\CLEAN_ARCH_GUIDE.md" set MISSING_FILES=1
if not exist "%CACHE_DIR%\references\DDD_GUIDE.md" set MISSING_FILES=1
if not exist "%CACHE_DIR%\references\TDD_GUIDE.md" set MISSING_FILES=1
if not exist "%CACHE_DIR%\references\SOLID_GUIDE.md" set MISSING_FILES=1
if not exist "%CACHE_DIR%\templates\RFC_TEMPLATE.md" set MISSING_FILES=1
if not exist "%CACHE_DIR%\templates\DOMAIN_MODEL_TEMPLATE.md" set MISSING_FILES=1

if %MISSING_FILES%==0 (
    echo [SUCCESS] All required files verified
) else (
    echo [WARNING] Some files are missing
)

REM Print summary
echo.
echo [SUCCESS] Installation completed successfully!
echo.
echo Plugin Details:
echo   Name: %PLUGIN_NAME%
echo   Version: %PLUGIN_VERSION%
echo   Location: %CACHE_DIR%
echo.
echo Usage:
echo   Restart Claude Code and use the skill by mentioning:
echo   - 'spec-driven development'
echo   - 'let's spec this out first'
echo   - 'I want to use RFC and domain modeling'
echo.
echo The skill will be automatically triggered when appropriate
echo.
pause
