#!/bin/bash

# Cross-platform installation script for Spec-Driven Development skill
# Works on: Linux, macOS, Windows (WSL, Git Bash, Cygwin)

set -e

# Detect operating system
detect_os() {
    case "$OSTYPE" in
        linux*)   echo "linux" ;;
        darwin*)  echo "macos" ;;
        cygwin*)  echo "windows" ;;
        msys*)    echo "windows" ;;
        win*)     echo "windows" ;;
        *)        echo "unknown" ;;
    esac
}

OS=$(detect_os)

# Colors for output (disable on Windows if not supported)
if [[ "$OS" != "windows" ]] || [[ -n "$WSL_DISTRO_NAME" ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

# Plugin metadata
PLUGIN_NAME="spec-driven-dev"
PLUGIN_VERSION="1.0.0"
MARKETPLACE="local"

# Functions
print_header() {
    if [[ "$OS" == "windows" && -z "$WSL_DISTRO_NAME" ]]; then
        echo "=========================================================="
        echo "  Spec-Driven Development Skill Setup Script"
        echo "=========================================================="
        echo ""
    else
        echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║     Spec-Driven Development Skill Setup Script           ║${NC}"
        echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
        echo ""
    fi
    echo "Detected OS: $OS"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

detect_claude_dir() {
    # Check common Claude Code directories based on OS
    if [[ -d "$HOME/.claude" ]]; then
        echo "$HOME/.claude"
        return 0
    fi

    # Platform-specific paths
    case "$OS" in
        "macos")
            if [[ -d "$HOME/Library/Application Support/Claude" ]]; then
                echo "$HOME/Library/Application Support/Claude"
                return 0
            fi
            ;;
        "windows")
            # Windows paths (works in WSL, Git Bash, Cygwin)
            if [[ -n "$APPDATA" && -d "$APPDATA/Claude" ]]; then
                echo "$APPDATA/Claude"
                return 0
            fi
            if [[ -d "/c/Users/$USER/AppData/Roaming/Claude" ]]; then
                echo "/c/Users/$USER/AppData/Roaming/Claude"
                return 0
            fi
            if [[ -d "$USERPROFILE/AppData/Roaming/Claude" ]]; then
                echo "$USERPROFILE/AppData/Roaming/Claude"
                return 0
            fi
            ;;
        "linux")
            if [[ -d "$HOME/.config/Claude" ]]; then
                echo "$HOME/.config/Claude"
                return 0
            fi
            ;;
    esac

    return 1
}

create_plugin_structure() {
    local install_dir="$1"
    local cache_dir="$install_dir/plugins/cache/$MARKETPLACE/$PLUGIN_NAME/$PLUGIN_VERSION"

    print_info "Creating plugin directory structure..."

    # Create directories
    mkdir -p "$cache_dir/.claude-plugin"
    mkdir -p "$cache_dir/agents"
    mkdir -p "$cache_dir/references"
    mkdir -p "$cache_dir/templates"

    echo "$cache_dir"
}

copy_plugin_files() {
    local cache_dir="$1"
    local repo_root="$2"

    print_info "Copying plugin files..."

    # Copy plugin metadata
    if [[ -f "$repo_root/.claude-plugin/plugin.json" ]]; then
        cp "$repo_root/.claude-plugin/plugin.json" "$cache_dir/.claude-plugin/"
        print_success "Copied plugin metadata"
    else
        print_error "plugin.json not found in repository"
        exit 1
    fi

    # Copy skill file
    if [[ -f "$repo_root/SKILL.md" ]]; then
        cp "$repo_root/SKILL.md" "$cache_dir/agents/"
        print_success "Copied main skill file"
    else
        print_error "SKILL.md not found in repository"
        exit 1
    fi

    # Copy reference guides
    if [[ -d "$repo_root/references" ]]; then
        cp -r "$repo_root/references/"* "$cache_dir/references/" 2>/dev/null || true
        print_success "Copied reference guides"
    fi

    # Copy templates
    if [[ -d "$repo_root/templates" ]]; then
        cp -r "$repo_root/templates/"* "$cache_dir/templates/" 2>/dev/null || true
        print_success "Copied templates"
    fi

    # Copy CLAUDE.md if it exists
    if [[ -f "$repo_root/CLAUDE.md" ]]; then
        cp "$repo_root/CLAUDE.md" "$cache_dir/"
        print_success "Copied CLAUDE.md"
    fi
}

update_installed_plugins() {
    local claude_dir="$1"
    local install_path="$2"
    local plugins_file="$claude_dir/plugins/installed_plugins.json"

    print_info "Updating installed plugins registry..."

    # Create plugins file if it doesn't exist
    if [[ ! -f "$plugins_file" ]]; then
        mkdir -p "$(dirname "$plugins_file")"
        echo '{"version": 2, "plugins": {}}' > "$plugins_file"
    fi

    # Get current timestamp (cross-platform)
    local timestamp
    if command -v date &> /dev/null; then
        if date +%s &> /dev/null; then
            timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ")
        else
            timestamp=$(date)
        fi
    else
        timestamp="2026-01-01T00:00:00.000Z"
    fi

    # Update the JSON file using a temporary file
    local temp_file=$(mktemp)

    # Use Python for JSON manipulation if available, otherwise use sed
    if command -v python3 &> /dev/null; then
        python3 << EOF
import json
import sys

try:
    with open('$plugins_file', 'r') as f:
        data = json.load(f)

    if 'plugins' not in data:
        data['plugins'] = {}

    plugin_key = "$PLUGIN_NAME@$MARKETPLACE"

    if plugin_key not in data['plugins']:
        data['plugins'][plugin_key] = []

    # Remove any existing installations with same path
    data['plugins'][plugin_key] = [p for p in data['plugins'][plugin_key] if p.get('installPath') != '$install_path']

    # Add new installation
    data['plugins'][plugin_key].append({
        'scope': 'user',
        'installPath': '$install_path',
        'version': '$PLUGIN_VERSION',
        'installedAt': '$timestamp',
        'lastUpdated': '$timestamp'
    })

    with open('$temp_file', 'w') as f:
        json.dump(data, f, indent=2)

    sys.exit(0)
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
EOF

        if [[ $? -eq 0 ]]; then
            mv "$temp_file" "$plugins_file"
            print_success "Updated plugins registry"
        else
            print_warning "Failed to update plugins registry (plugin will still work)"
            rm -f "$temp_file"
        fi
    else
        print_warning "Python not found - skipping registry update (plugin will still work)"
    fi
}

verify_installation() {
    local cache_dir="$1"

    print_info "Verifying installation..."

    local required_files=(
        ".claude-plugin/plugin.json"
        "agents/SKILL.md"
        "references/CLEAN_ARCH_GUIDE.md"
        "references/DDD_GUIDE.md"
        "references/TDD_GUIDE.md"
        "references/SOLID_GUIDE.md"
        "templates/RFC_TEMPLATE.md"
        "templates/DOMAIN_MODEL_TEMPLATE.md"
    )

    local missing_files=()

    for file in "${required_files[@]}"; do
        if [[ ! -f "$cache_dir/$file" ]]; then
            missing_files+=("$file")
        fi
    done

    if [[ ${#missing_files[@]} -eq 0 ]]; then
        print_success "All required files verified"
        return 0
    else
        print_warning "Some files are missing: ${missing_files[*]}"
        return 1
    fi
}

main() {
    print_header

    # Detect Claude Code directory
    print_info "Detecting Claude Code installation..."
    CLAUDE_DIR=$(detect_claude_dir)

    if [[ -z "$CLAUDE_DIR" ]]; then
        print_error "Could not find Claude Code installation directory"
        echo ""
        echo "Claude Code may not be installed, or it's in an unusual location."
        echo ""
        echo "Manual setup instructions:"
        if [[ "$OS" == "windows" ]]; then
            echo "  1. Install Claude Code from: https://claude.ai/code"
            echo "  2. Run this script from Git Bash or WSL"
        else
            echo "  1. Install Claude Code from: https://claude.ai/code"
            echo "  2. Run this script again"
        fi
        echo ""
        echo "For manual installation, see: https://github.com/0xPuncker/ai-spec-driven/blob/main/INSTALL.md"
        exit 1
    fi

    print_success "Found Claude Code at: $CLAUDE_DIR"

    # Show platform-specific notes
    if [[ "$OS" == "windows" && -z "$WSL_DISTRO_NAME" ]]; then
        print_info "Running on Windows (Git Bash/Cygwin)"
    elif [[ "$OS" == "windows" && -n "$WSL_DISTRO_NAME" ]]; then
        print_info "Running on Windows (WSL - $WSL_DISTRO_NAME)"
    fi

    # Get repository root (script is now in scripts/ subdirectory)
    if [[ -n "$GITHUB_ACTIONS" ]] || [[ -n "$CI" ]]; then
        REPO_ROOT="${GITHUB_WORKSPACE:-$PWD}"
    else
        # Go up one level since we're in scripts/ directory
        REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    fi

    print_info "Repository root: $REPO_ROOT"

    # Create plugin structure
    CACHE_DIR=$(create_plugin_structure "$CLAUDE_DIR")
    print_success "Created plugin directory: $CACHE_DIR"

    # Copy files
    copy_plugin_files "$CACHE_DIR" "$REPO_ROOT"

    # Update installed plugins registry
    update_installed_plugins "$CLAUDE_DIR" "$CACHE_DIR"

    # Verify installation
    echo ""
    verify_installation "$CACHE_DIR"

    # Print summary
    echo ""
    print_success "Installation completed successfully!"
    echo ""
    echo -e "${BLUE}Plugin Details:${NC}"
    echo "  Name: $PLUGIN_NAME"
    echo "  Version: $PLUGIN_VERSION"
    echo "  Location: $CACHE_DIR"
    echo ""
    echo -e "${BLUE}Usage:${NC}"
    echo "  Restart Claude Code and use the skill by mentioning:"
    echo "  - 'spec-driven development'"
    echo "  - 'let's spec this out first'"
    echo "  - 'I want to use RFC and domain modeling'"
    echo ""
    print_success "The skill will be automatically triggered when appropriate"
}

# Run main function
main "$@"
