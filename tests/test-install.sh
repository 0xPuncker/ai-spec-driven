#!/bin/bash

# Test script for install.sh
# This validates the installation script logic without actually installing

set -e

echo "🧪 Testing installation script..."

# Test 1: Script exists and is executable
echo "Test 1: Checking script exists..."
if [[ -x "install.sh" ]]; then
    echo "✅ Script is executable"
else
    echo "❌ Script is not executable"
    exit 1
fi

# Test 2: Script has proper shebang
echo "Test 2: Checking shebang..."
if head -1 setup.sh | grep -q "#!/bin/bash"; then
    echo "✅ Proper shebang found"
else
    echo "❌ Invalid shebang"
    exit 1
fi

# Test 3: Required plugin metadata exists
echo "Test 3: Checking plugin metadata..."
if [[ -f ".claude-plugin/plugin.json" ]]; then
    echo "✅ Plugin metadata exists"
    # Validate JSON
    if python3 -m json.tool .claude-plugin/plugin.json > /dev/null 2>&1; then
        echo "✅ Plugin metadata is valid JSON"
    else
        echo "❌ Plugin metadata is invalid JSON"
        exit 1
    fi
else
    echo "❌ Plugin metadata not found"
    exit 1
fi

# Test 4: Required skill files exist
echo "Test 4: Checking required skill files..."
required_files=(
    "SKILL.md"
    "references/CLEAN_ARCH_GUIDE.md"
    "references/DDD_GUIDE.md"
    "references/TDD_GUIDE.md"
    "references/SOLID_GUIDE.md"
    "templates/RFC_TEMPLATE.md"
    "templates/DOMAIN_MODEL_TEMPLATE.md"
)

all_files_exist=true
for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file (missing)"
        all_files_exist=false
    fi
done

if [[ "$all_files_exist" = false ]]; then
    echo "❌ Some required files are missing"
    exit 1
fi

# Test 5: Script syntax validation
echo "Test 5: Validating script syntax..."
if bash -n install.sh 2>/dev/null; then
    echo "✅ Script syntax is valid"
else
    echo "❌ Script has syntax errors"
    exit 1
fi

# Test 6: Check for dangerous operations
echo "Test 6: Checking for safe operations..."
dangerous_commands=(
    "rm -rf /"
    "rm -rf /*"
    "dd if="
    ":(){ :|:& };:"
    "chmod 777 /"
)

script_dangerous=false
for cmd in "${dangerous_commands[@]}"; do
    if grep -q "$cmd" setup.sh; then
        echo "❌ Dangerous command found: $cmd"
        script_dangerous=true
    fi
done

if [[ "$script_dangerous" = true ]]; then
    echo "❌ Script contains dangerous commands"
    exit 1
else
    echo "✅ No dangerous commands found"
fi

# Test 7: Check script functions
echo "Test 7: Checking required functions..."
required_functions=(
    "print_header"
    "print_success"
    "print_error"
    "detect_os"
    "detect_claude_dir"
    "create_plugin_structure"
    "copy_plugin_files"
    "update_installed_plugins"
    "verify_installation"
    "main"
)

all_functions_exist=true
for func in "${required_functions[@]}"; do
    if grep -q "^$func()" setup.sh; then
        echo "  ✅ $func()"
    else
        echo "  ❌ $func() (missing)"
        all_functions_exist=false
    fi
done

if [[ "$all_functions_exist" = false ]]; then
    echo "❌ Some required functions are missing"
    exit 1
fi

echo ""
echo "🎉 All tests passed! The installation script is ready to use."
echo ""
echo "To install the skill, run:"
echo "  ./setup.sh          # Linux/macOS"
echo "  ./setup.bat         # Windows"
echo "  powershell ./setup.ps1  # Windows PowerShell"
echo ""
echo "Or install remotely:"
echo "  curl -sSL https://raw.githubusercontent.com/0xPuncker/ai-spec-driven/main/setup.sh | bash"
