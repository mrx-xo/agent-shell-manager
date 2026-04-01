# CLAUDE.md

## Overview

Fork of agent-shell-manager — a tabulated-list UI for managing `agent-shell` buffers in Emacs. Single-file package: `agent-shell-manager.el`.

## Development Workflow

1. **Edit** `agent-shell-manager.el` directly (it lives in `~/.emacs.d/elpaca/repos/agent-shell-manager/`)

2. **Load into sandbox** to test without affecting the main Emacs session:
   ```bash
   emacsclient -s sandbox --eval '(load-file "~/.emacs.d/elpaca/repos/agent-shell-manager/agent-shell-manager.el")'
   ```

3. **Test locally** in the sandbox Emacs (launch with `Cmd+Shift+S` or `~/.dotfiles/scripts/emacs-sandbox.sh`)

4. **Commit and push** once verified

5. **Deploy to main Emacs** with `M-x elpaca-rebuild RET agent-shell-manager RET`

## Architecture

- **Single file**: `agent-shell-manager.el` (~1050 lines)
- **Derived from**: `tabulated-list-mode`
- **Dependencies**: `agent-shell`, `tabulated-list` (built-in)
- **Auto-refresh**: Timer every 2 seconds
- **Grouping**: Buffers grouped by project root (via projectile)
- **Filtering**: Cycle through status filters with `f`
- **Preview mode**: Split view with live buffer preview
- **Buffer labels**: Display names shown in the Buffer column without renaming the actual buffer
