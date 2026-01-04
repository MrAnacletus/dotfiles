# AGENTS.md - Developer Guide for Agentic Coding

This repository contains unified Linux dotfiles configurations with the Badwolf theme. The following guide helps agentic coding tools operate effectively within this repository.

## Repository Overview

- **Type**: Linux dotfiles and configuration files
- **Languages**: Bash, Python, Lua, Shell scripts
- **Configuration Formats**: Conf, CSS, JSON, YAML-like configs
- **Structure**: Mirrors standard Linux config locations (.config, .local, scripts, themes)

## Build/Test/Lint Commands

This repository is **not a traditional software project** with builds or tests. Instead, it contains configuration files for various Linux tools. Validation approaches:

### Installation & Dry Run Testing
```bash
# Set environment variable pointing to dotfiles repo
export DEV_ENV=/home/shinobu/repos/dotfiles

# Dry run to preview what would be installed
./scripts/installdots.sh --dry

# Actually install/sync dotfiles
./scripts/installdots.sh
```

### Script Validation
```bash
# Lint shell scripts for syntax errors
shellcheck .config/**/*.sh scripts/*.sh

# Check Python syntax
python3 -m py_compile .config/**/*.py

# Check Lua syntax (if lua installed)
lua -c .config/nvim/lua/**/*.lua
```

### JSON Validation
```bash
# Validate JSON configs
jq empty .config/nvim/lazy-lock.json
jq empty .config/Code/User/settings.json
```

## Code Style Guidelines

### Shell Scripts (.sh)

**Shebang and Safety:**
- Use `#!/usr/bin/env bash` for bash scripts
- Start scripts with `set -euo pipefail` for safety
- Use meaningful variable names in UPPERCASE for constants

**Formatting:**
- Use 4-space indentation (matches Lua/Python)
- Quote all variables: `"$var"` not `$var`
- Use `[[ ... ]]` for conditions instead of `[ ... ]`
- Use functions to organize code: `function_name() { ... }`

**Error Handling:**
- Check for required directories with `require_dir()` helper
- Check for required files with `require_file()` helper
- Use stderr for errors: `echo "error" >&2`
- Return non-zero exit codes on error: `return 1`

**Example Pattern:**
```bash
#!/usr/bin/env bash
set -euo pipefail

require_dir() {
    if [[ ! -d "$1" ]]; then
        echo "missing dir: $1" >&2
        return 1
    fi
    return 0
}
```

### Python Scripts (.py)

**General Style:**
- Follow PEP 8: use 4-space indentation
- Use `#!/usr/bin/env python3` shebang
- Use docstrings for functions and modules
- Use snake_case for functions/variables, UPPER_CASE for constants

**Configuration & Structure:**
- Define configuration constants at the top in uppercase
- Separate configuration section with comment markers: `# --- CONFIGURATION ---`
- Group related functions together

**Error Handling:**
- Use try/except for subprocess operations
- Capture subprocess output with `check_output()` when needed
- Provide clear error messages

**Example Pattern:**
```python
#!/usr/bin/env python3
import subprocess
import sys

# --- CONFIGURATION ---
ENABLE_NOTIFICATIONS = True

def notify(message):
    """Send a notification if enabled."""
    if ENABLE_NOTIFICATIONS:
        subprocess.run(["notify-send", message])

if __name__ == "__main__":
    main()
```

### Lua Scripts (.lua)

**Formatting & Structure:**
- Use 2-space indentation for Lua (standard in Neovim configs)
- Use descriptive variable names
- Add comments for configuration sections: `-- This is a section`

**Configuration Style:**
- Use `vim.opt` for vim options
- Use `vim.g` for global variables
- Use `vim.cmd` for vim commands when needed
- Group related configurations

**Example Pattern:**
```lua
-- Section header
local opt = vim.opt

opt.expandtab = true      -- Use spaces instead of tabs
opt.shiftwidth = 4        -- Size of an indent
opt.tabstop = 4           -- Spaces per tab character
```

### Configuration Files (.conf, .css, .rasi, .json)

**General Principles:**
- Maintain consistent indentation (usually 2 or 4 spaces)
- Use meaningful section comments
- Keep color values consistent with Badwolf theme
- Follow existing formatting patterns in the file

**Badwolf Color Palette:**
- Background: `#1c1b1a`
- Foreground: `#f8f6f2`
- Surface: `#35322d`
- Primary: `#ff0044`
- Secondary: `#fade3e`
- Accent: `#afd700`
- Border: `rgba(255, 255, 255, 0.10)`
- Muted: `rgba(255, 255, 255, 0.40)`

## Naming Conventions

### Files & Directories
- Use lowercase with hyphens: `monitor-setup.sh`, `badwolf-theme.conf`
- Mirror standard Linux paths: `.config/`, `.local/`, `scripts/`, `themes/`
- Configuration categories: `hypr/`, `nvim/`, `waybar/`, `kitty/`, etc.

### Functions (Shell)
- Use snake_case: `require_dir()`, `update_files()`, `execute_with_retry()`
- Prefix helpers: `execute_with_retry()` for common patterns
- Keep function names descriptive

### Functions (Python)
- Use snake_case: `get_sinks()`, `toggle_sink()`, `notify()`
- Use present tense verbs: `get_`, `set_`, `check_`, `toggle_`

### Variables
- Constants: UPPER_CASE (`SKIP_SINK_NAMES`, `PRIMARY`, `MODE`)
- Local variables: lowercase or camelCase (language dependent)
- Meaningful names over abbreviations

## Import/Include Patterns

### Shell Scripts
- Import is implicit through sourcing: `. ./helpers.sh`
- Avoid global imports when possible
- Keep scripts self-contained

### Python Scripts
- Import standard library first
- Then import third-party (subprocess, requests, etc.)
- No blank line needed between import groups for small scripts
- Example order:
  ```python
  import subprocess
  import re
  import sys
  from datetime import datetime
  ```

### Lua Scripts
- Lua has minimal imports in dotfiles context
- Use vim module directly: `vim.opt`, `vim.g`, `vim.cmd`
- Require other modules at top if needed: `require('plugin.module')`

## Comments & Documentation

**Comment Style:**
- Shell: `# comment` (use for sections and clarifications)
- Python: `# comment` with docstrings for functions
- Lua: `-- comment` with inline explanations for vim options
- Config files: Follow the format's convention

**Documentation:**
- Add inline comments for non-obvious logic
- Use section headers to organize code
- Document configuration constants and their purpose
- Example:
  ```bash
  # Obtener monitores activamente activos
  mapfile -t CONNECTED < <(
      hyprctl monitors -j | jq -r '.[].description'
  )
  ```

## Installation & Integration

The repository uses `installdots.sh` as the main integration point:

- **Source**: Environment variable `DEV_ENV` must point to dotfiles directory
- **Execution**: `./scripts/installdots.sh` syncs files to proper locations
- **Dry Mode**: Use `--dry` flag to preview changes without applying
- **Preservation**: Code configs are preserved (rsync -a), others are replaced

Example workflow:
```bash
export DEV_ENV=/home/shinobu/repos/dotfiles
./scripts/installdots.sh --dry  # Preview
./scripts/installdots.sh         # Apply changes
hyprctl reload                   # Reload Hyprland
```

## Special Notes

- **Language Mix**: This is intentionally polyglot; each tool has its own language
- **No Build System**: This is configuration-as-code, not a compilable project
- **Theme Consistency**: Always maintain Badwolf color consistency across files
- **Breaking Changes**: Test with `--dry` before committing changes
- **Cross-Platform**: Focus on Linux/Hyprland ecosystem; avoid macOS/Windows-specific code

## Common Patterns

**Environment Variable Checking:**
```bash
if [ -z "$VARIABLE" ]; then
    echo "env var VARIABLE is required"
    exit 1
fi
```

**Retry Logic:**
```bash
execute_with_retry() {
    local attempt=1
    while (( attempt <= RETRY_ATTEMPTS )); do
        if eval "$cmd" 2>/dev/null; then return 0; fi
        ((attempt++))
    done
    return 1
}
```

**Notifications (Python):**
```python
def notify(message):
    """Send a notification."""
    if ENABLE_NOTIFICATIONS:
        subprocess.run(["notify-send", "-a", "App Name", message])
```

## File Organization

When adding new files or configurations:
1. Place them in the appropriate `.config/` subdirectory
2. Follow existing naming conventions
3. Add inline comments for complex logic
4. Test with `installdots.sh --dry` before committing
5. Update README.md if adding major new configurations
