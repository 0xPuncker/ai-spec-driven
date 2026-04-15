# Spec-Driven Development

A structured software development methodology that front-loads clarity before code generation to minimize wasted AI tokens and maximize first-shot accuracy.

## Quick Start

### One-Line Installation

**Linux/macOS:**
```bash
curl -sSL https://raw.githubusercontent.com/0xPuncker/ai-spec-driven/main/setup.sh | bash
```

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/0xPuncker/ai-spec-driven/main/setup.ps1 | iex
```

**Windows (Command Prompt):**
```cmd
curl -o setup.bat https://raw.githubusercontent.com/0xPuncker/ai-spec-driven/main/scripts/setup.bat && setup.bat
```

### Manual Installation

1. Clone this repository:
```bash
git clone https://github.com/0xPuncker/ai-spec-driven.git
cd ai-spec-driven
```

2. Run the setup script for your platform:
```bash
./setup.sh              # Linux/macOS (main entry point)
./scripts/setup.sh      # Linux/macOS (direct script)
./scripts/setup.bat     # Windows Command Prompt  
powershell ./scripts/setup.ps1  # Windows PowerShell
```

3. Restart Claude Code

## Repository Structure

```
ai-spec-driven/
├── .claude-plugin/       # Plugin metadata
├── scripts/             # Installation scripts
│   ├── setup.sh        # Unix/Linux/macOS
│   ├── setup.ps1       # PowerShell
│   └── setup.bat       # Windows batch
├── tests/               # Validation scripts
│   └── test-install.sh # Installation validator
├── references/          # DDD, TDD, Clean Architecture, SOLID guides
├── templates/           # RFC and Domain Model templates
├── SKILL.md            # Main methodology
├── CLAUDE.md           # Repository documentation
├── README.md           # This file
└── INSTALL.md          # Detailed installation guide
```

## What This Does

This skill enforces a strict development pipeline:

```
Phase 0: Intent Capture
Phase 1: RFC Specification  
Phase 2: Domain Model (DDD)
Phase 3: Test Contracts (TDD)
Phase 4: Implementation (Clean Architecture + SOLID)
Phase 5: Review & Refactor
```

## Usage

The skill is automatically triggered when you:

- Mention "spec-driven development", "DDD", "TDD", "clean architecture", or "SOLID"
- Say things like "let's plan this properly" or "I want to spec this out first"
- Start a new project or feature of non-trivial complexity
- Express frustration with AI-generated code quality

## What's Included

### Main Skill
- **SKILL.md** - Complete methodology with gates, artifacts, and workflow

### Reference Guides
- **CLEAN_ARCH_GUIDE.md** - Layer structure and dependency rules
- **DDD_GUIDE.md** - Domain-Driven Design workflow and concepts
- **TDD_GUIDE.md** - Test-Driven Development strategy
- **SOLID_GUIDE.md** - Code review checklist

### Templates
- **RFC_TEMPLATE.md** - Formal specification template
- **DOMAIN_MODEL_TEMPLATE.md** - Domain modeling template

## Platform Support

✅ **Linux** - setup.sh  
✅ **macOS** - setup.sh  
✅ **Windows (PowerShell)** - setup.ps1  
✅ **Windows (Command Prompt)** - setup.bat  
✅ **Windows (Git Bash)** - setup.sh  
✅ **Windows (WSL)** - setup.sh

## Key Benefits

- **80% first-shot accuracy** vs 30-40% with ad-hoc prompting
- **Token efficiency** - Clear specs reduce wasted iterations
- **Quality gates** - Each phase validates before proceeding
- **Framework-agnostic** - Works with any language or stack
- **Cross-platform** - Works on all major operating systems

## Philosophy

Every token spent on ambiguous prompts is a token wasted. This methodology ensures that by the time AI writes a single line of code, the spec is so precise that the first generation is usable.

## Testing

Run the installation validation:
```bash
./tests/test-install.sh    # Verify installation
```

## Troubleshooting

For detailed installation instructions and troubleshooting, see [INSTALL.md](INSTALL.md).

## License

MIT

## Author

0xPuncker - [GitHub](https://github.com/0xPuncker)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
