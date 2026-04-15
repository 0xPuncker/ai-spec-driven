# Installation Guide

## One-Line Installation (Recommended)

The easiest way to install this skill is to run this command in your terminal:

### Unix/Linux/macOS
```bash
curl -sSL https://raw.githubusercontent.com/0xPuncker/ai-spec-driven/main/setup.sh | bash
```

### Windows PowerShell
```powershell
irm https://raw.githubusercontent.com/0xPuncker/ai-spec-driven/main/setup.ps1 | iex
```

### Windows Command Prompt
```cmd
curl -o setup.bat https://raw.githubusercontent.com/0xPuncker/ai-spec-driven/main/scripts/setup.bat && setup.bat
```

This will:
- ✅ Detect your Claude Code installation
- ✅ Create the necessary plugin structure
- ✅ Install all skill files, references, and templates
- ✅ Register the plugin with Claude Code
- ✅ Verify the installation

## Alternative Installation Methods

### Method 1: Clone and Setup

```bash
# Clone the repository
git clone https://github.com/0xPuncker/ai-spec-driven.git
cd ai-spec-driven

# Run the setup script (choose your platform)
./setup.sh              # Linux/macOS (recommended)
./scripts/setup.sh      # Linux/macOS (direct)
./scripts/setup.bat     # Windows CMD
powershell ./scripts/setup.ps1  # Windows PowerShell
```

### Method 2: Download and Setup

#### Unix/Linux/macOS
```bash
# Download the main setup script
curl -O https://raw.githubusercontent.com/0xPuncker/ai-spec-driven/main/setup.sh

# Make it executable and run
chmod +x setup.sh
./setup.sh
```

#### Windows PowerShell
```powershell
# Download and run in one step
irm https://raw.githubusercontent.com/0xPuncker/ai-spec-driven/main/setup.ps1 | iex
```

#### Windows Command Prompt
```cmd
REM Download the batch file
curl -o setup.bat https://raw.githubusercontent.com/0xPuncker/ai-spec-driven/main/scripts/setup.bat

REM Run it
setup.bat
```

## Repository Structure

The installation scripts are organized as follows:

```
ai-spec-driven/
├── setup.sh              # Main entry point (Unix/Linux/macOS)
├── scripts/              # Installation scripts
│   ├── setup.sh         # Unix/Linux/macOS implementation
│   ├── setup.ps1        # PowerShell implementation
│   └── setup.bat        # Batch implementation
├── tests/                # Validation scripts
│   └── test-install.sh  # Installation validator
├── .claude-plugin/       # Plugin metadata
├── references/           # Reference guides
├── templates/            # Templates
└── SKILL.md             # Main skill file
```

## What Gets Installed

The script creates the following structure in your Claude Code plugins directory:

```
~/.claude/plugins/cache/local/spec-driven-dev/1.0.0/
├── .claude-plugin/
│   └── plugin.json           # Plugin metadata
├── agents/
│   └── SKILL.md              # Main methodology skill
├── references/
│   ├── CLEAN_ARCH_GUIDE.md   # Clean Architecture guide
│   ├── DDD_GUIDE.md          # Domain-Driven Design guide
│   ├── TDD_GUIDE.md          # Test-Driven Development guide
│   └── SOLID_GUIDE.md        # SOLID principles guide
├── templates/
│   ├── DOMAIN_MODEL_TEMPLATE.md
│   └── RFC_TEMPLATE.md
└── CLAUDE.md                 # Repository documentation
```

## Post-Installation

### 1. Restart Claude Code

Close and reopen Claude Code to load the new skill.

### 2. Verify Installation

The skill will be automatically available. You can trigger it by saying:

- "I want to use spec-driven development"
- "Let's spec this out first"
- "Help me create an RFC for this feature"

### 3. Test the Installation

Run the validation script to verify everything is installed correctly:

```bash
./tests/test-install.sh
```

## Troubleshooting

### Claude Code directory not found

If the script can't find your Claude Code installation:

```bash
# Manually specify the directory
export CLAUDE_DIR="$HOME/.claude"
./setup.sh
```

### Permission denied

If you get a permission error:

```bash
# Download and run with proper permissions
curl -O https://raw.githubusercontent.com/0xPuncker/ai-spec-driven/main/setup.sh
chmod +x setup.sh
./setup.sh
```

### Windows-specific issues

**Git Bash not found:**
- Install Git for Windows from https://git-scm.com/download/win
- Use the provided PowerShell script instead

**PowerShell execution policy:**
```powershell
# If you get execution policy errors, run:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Path issues:**
- Use WSL (Windows Subsystem for Linux) for best compatibility
- Or use the PowerShell script: `./scripts/setup.ps1`

### Script location errors

If you get errors about script locations, make sure you're running from the correct directory:

```bash
# You should be in the ai-spec-driven root directory
pwd  # Should end with /ai-spec-driven
ls   # Should show setup.sh, scripts/, tests/, etc.
```

### Verification fails

If the installation verification fails:

1. Check that all required files exist in the repository
2. Make sure you have write permissions to the Claude Code plugins directory
3. Try running the setup script with verbose output

### Uninstallation

To remove the skill:

```bash
# Remove the plugin directory
rm -rf ~/.claude/plugins/cache/local/spec-driven-dev

# On Windows (PowerShell):
Remove-Item -Recurse -Force "$env:USERPROFILE\.claude\plugins\cache\local\spec-driven-dev"

# On Windows (CMD):
rmdir /s /q "%USERPROFILE%\.claude\plugins\cache\local\spec-driven-dev"
```

## Advanced: Local Development

If you want to modify the skill:

1. Clone the repository
2. Make your changes
3. Run `./setup.sh` to test your changes
4. Run `./tests/test-install.sh` to validate
5. Iterate until satisfied
6. Submit a pull request

## System Requirements

- Claude Code installed
- Bash shell (macOS, Linux, or WSL on Windows)
- curl for downloading the script
- Python 3 (optional, for better plugin registry updates)

## Security Note

This installation script:
- ✅ Only writes to your local Claude Code plugins directory
- ✅ Does not modify any system files
- ✅ Does not require sudo/administrator privileges
- ✅ Uses HTTPS for secure downloads
- ✅ Is open source - you can review the code

You can always review the script contents before running:

```bash
curl -sSL https://raw.githubusercontent.com/0xPuncker/ai-spec-driven/main/setup.sh | less
```

## Next Steps

After installation, check out the [main README](README.md) for usage instructions and examples.
