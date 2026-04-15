# Spec-Driven Development Skill Setup Script for Windows PowerShell
# Compatible with: Windows PowerShell 5.1+ and PowerShell Core 7+

# Plugin metadata
$PLUGIN_NAME = "spec-driven-dev"
$PLUGIN_VERSION = "1.0.0"
$MARKETPLACE = "local"

# Functions
function Print-Header {
    Write-Host "==========================================================" -ForegroundColor Cyan
    Write-Host "  Spec-Driven Development Skill Setup Script           " -ForegroundColor Cyan
    Write-Host "==========================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Detected OS: Windows" -ForegroundColor Yellow
    Write-Host ""
}

function Print-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Print-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Print-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Print-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Detect-ClaudeDir {
    # Check common Claude Code directories on Windows
    $appdataPath = Join-Path $env:APPDATA "Claude"
    $userprofilePath = Join-Path $env:USERPROFILE ".claude"

    if (Test-Path $appdataPath) {
        return $appdataPath
    }

    if (Test-Path $userprofilePath) {
        return $userprofilePath
    }

    return $null
}

function Create-PluginStructure {
    param([string]$InstallDir)

    $cacheDir = Join-Path $InstallDir "plugins\cache\$MARKETPLACE\$PLUGIN_NAME\$PLUGIN_VERSION"

    Print-Info "Creating plugin directory structure..."

    # Create directories
    $directories = @(
        (Join-Path $cacheDir ".claude-plugin"),
        (Join-Path $cacheDir "agents"),
        (Join-Path $cacheDir "references"),
        (Join-Path $cacheDir "templates")
    )

    foreach ($dir in $directories) {
        if (!(Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }

    return $cacheDir
}

function Copy-PluginFiles {
    param([string]$CacheDir, [string]$RepoRoot)

    Print-Info "Copying plugin files..."

    # Copy plugin metadata
    $pluginJson = Join-Path $RepoRoot ".claude-plugin\plugin.json"
    if (Test-Path $pluginJson) {
        Copy-Item -Path $pluginJson -Destination (Join-Path $CacheDir ".claude-plugin\") -Force
        Print-Success "Copied plugin metadata"
    } else {
        Print-Error "plugin.json not found in repository"
        exit 1
    }

    # Copy skill file
    $skillFile = Join-Path $RepoRoot "SKILL.md"
    if (Test-Path $skillFile) {
        Copy-Item -Path $skillFile -Destination (Join-Path $CacheDir "agents\") -Force
        Print-Success "Copied main skill file"
    } else {
        Print-Error "SKILL.md not found in repository"
        exit 1
    }

    # Copy reference guides
    $referencesDir = Join-Path $RepoRoot "references"
    if (Test-Path $referencesDir) {
        Copy-Item -Path "$referencesDir\*" -Destination (Join-Path $CacheDir "references\") -Recurse -Force
        Print-Success "Copied reference guides"
    }

    # Copy templates
    $templatesDir = Join-Path $RepoRoot "templates"
    if (Test-Path $templatesDir) {
        Copy-Item -Path "$templatesDir\*" -Destination (Join-Path $CacheDir "templates\") -Recurse -Force
        Print-Success "Copied templates"
    }

    # Copy CLAUDE.md if it exists
    $claudeMd = Join-Path $RepoRoot "CLAUDE.md"
    if (Test-Path $claudeMd) {
        Copy-Item -Path $claudeMd -Destination $CacheDir -Force
        Print-Success "Copied CLAUDE.md"
    }
}

function Update-InstalledPlugins {
    param([string]$ClaudeDir, [string]$InstallPath)

    Print-Info "Updating installed plugins registry..."

    $pluginsFile = Join-Path $ClaudeDir "plugins\installed_plugins.json"

    # Create plugins file if it doesn't exist
    if (!(Test-Path $pluginsFile)) {
        $pluginsDir = Split-Path $pluginsFile -Parent
        if (!(Test-Path $pluginsDir)) {
            New-Item -ItemType Directory -Path $pluginsDir -Force | Out-Null
        }
        '{"version": 2, "plugins": {}}' | Out-File -FilePath $pluginsFile -Encoding utf8
    }

    # Update JSON using PowerShell
    try {
        $timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")

        $pluginsData = Get-Content $pluginsFile -Raw | ConvertFrom-Json

        if ($null -eq $pluginsData.plugins) {
            $pluginsData | Add-Member -Type NoteProperty -Name "plugins" -Value @{}
        }

        $pluginKey = "$PLUGIN_NAME@$MARKETPLACE"

        if ($null -eq $pluginsData.plugins.$pluginKey) {
            $pluginsData.plugins | Add-Member -Type NoteProperty -Name $pluginKey -Value @()
        }

        # Remove existing installations with same path
        $pluginsData.plugins.$pluginKey = $pluginsData.plugins.$pluginKey | Where-Object { $_.installPath -ne $InstallPath }

        # Add new installation
        $newInstall = @{
            scope = "user"
            installPath = $InstallPath
            version = $PLUGIN_VERSION
            installedAt = $timestamp
            lastUpdated = $timestamp
        }

        $pluginsData.plugins.$pluginKey += $newInstall

        # Save back to file
        $pluginsData | ConvertTo-Json -Depth 10 | Out-File -FilePath $pluginsFile -Encoding utf8

        Print-Success "Updated plugins registry"
    } catch {
        Print-Warning "Failed to update plugins registry (plugin will still work)"
    }
}

function Verify-Installation {
    param([string]$CacheDir)

    Print-Info "Verifying installation..."

    $requiredFiles = @(
        ".claude-plugin\plugin.json",
        "agents\SKILL.md",
        "references\CLEAN_ARCH_GUIDE.md",
        "references\DDD_GUIDE.md",
        "references\TDD_GUIDE.md",
        "references\SOLID_GUIDE.md",
        "templates\RFC_TEMPLATE.md",
        "templates\DOMAIN_MODEL_TEMPLATE.md"
    )

    $missingFiles = @()

    foreach ($file in $requiredFiles) {
        $filePath = Join-Path $CacheDir $file
        if (!(Test-Path $filePath)) {
            $missingFiles += $file
        }
    }

    if ($missingFiles.Count -eq 0) {
        Print-Success "All required files verified"
        return $true
    } else {
        Print-Warning "Some files are missing: $($missingFiles -join ', ')"
        return $false
    }
}

# Main execution
try {
    Print-Header

    # Detect Claude Code directory
    Print-Info "Detecting Claude Code installation..."
    $claudeDir = Detect-ClaudeDir

    if ($null -eq $claudeDir) {
        Print-Error "Could not find Claude Code installation directory"
        Write-Host ""
        Write-Host "Claude Code may not be installed. Please install it from:" -ForegroundColor Yellow
        Write-Host "https://claude.ai/code" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "For manual installation, see:" -ForegroundColor Yellow
        Write-Host "https://github.com/0xPuncker/ai-spec-driven/blob/main/INSTALL.md" -ForegroundColor Cyan
        Read-Host "Press Enter to exit"
        exit 1
    }

    Print-Success "Found Claude Code at: $claudeDir"

    # Get repository root
    $repoRoot = Split-Path $PSScriptRoot
    Print-Info "Repository root: $repoRoot"

    # Create plugin structure
    $cacheDir = Create-PluginStructure -InstallDir $claudeDir
    Print-Success "Created plugin directory: $cacheDir"

    # Copy files
    Copy-PluginFiles -CacheDir $cacheDir -RepoRoot $repoRoot

    # Update installed plugins registry
    Update-InstalledPlugins -ClaudeDir $claudeDir -InstallPath $cacheDir

    # Verify installation
    Write-Host ""
    Verify-Installation -CacheDir $cacheDir

    # Print summary
    Write-Host ""
    Print-Success "Installation completed successfully!"
    Write-Host ""
    Write-Host "Plugin Details:" -ForegroundColor Cyan
    Write-Host "  Name: $PLUGIN_NAME"
    Write-Host "  Version: $PLUGIN_VERSION"
    Write-Host "  Location: $cacheDir"
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Cyan
    Write-Host "  Restart Claude Code and use the skill by mentioning:"
    Write-Host "  - 'spec-driven development'"
    Write-Host "  - 'let's spec this out first'"
    Write-Host "  - 'I want to use RFC and domain modeling'"
    Write-Host ""
    Print-Success "The skill will be automatically triggered when appropriate"

} catch {
    Print-Error "An error occurred: $_"
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Read-Host "Press Enter to exit"
