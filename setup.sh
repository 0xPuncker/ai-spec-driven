#!/bin/bash
# Main entry point for Spec-Driven Development skill installation
# This script delegates to the platform-specific setup script

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Spec-Driven Development - Quick Install              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Detect OS and run appropriate script
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

echo -e "${YELLOW}Detected OS: $OS${NC}"
echo ""

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Run the appropriate setup script
case "$OS" in
    "windows")
        if command -v powershell &> /dev/null; then
            echo "Running PowerShell setup..."
            powershell -ExecutionPolicy Bypass -File "$SCRIPT_DIR/scripts/setup.ps1"
        elif [ -f "$SCRIPT_DIR/scripts/setup.bat" ]; then
            echo "Running batch setup..."
            cmd //c "$SCRIPT_DIR/scripts/setup.bat"
        else
            echo "Error: No suitable setup script found for Windows"
            exit 1
        fi
        ;;
    *)
        # Unix/Linux/macOS
        if [ -f "$SCRIPT_DIR/scripts/setup.sh" ]; then
            echo "Running Unix/Linux/macOS setup..."
            bash "$SCRIPT_DIR/scripts/setup.sh"
        else
            echo "Error: setup.sh not found in scripts/ directory"
            exit 1
        fi
        ;;
esac
