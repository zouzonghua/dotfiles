# dotfiles

Personal configuration files managed with **GNU Stow**.

## Requirements

- Bash, OpenSSH, GNU Stow, and awk
- Git 2.37+
- Neovim 0.12+ (optional)
- Node.js and `npx` for Markdown Preview (optional)
- Personal/work SSH key pairs matching `git/.config/git/*.identity`

## Bootstrap

1. **Install GNU Stow**
   ```sh
   # macOS
   brew install stow

   # Debian/Ubuntu
   sudo apt install stow
   ```

2. **Clone and Install**
   ```sh
   git clone https://github.com/zouzonghua/dotfiles.git ~/personal/dotfiles
   cd ~/personal/dotfiles
   make dry-run  # Check conflicts without changing HOME
   make install  # Fail safely on conflicts
   
   # Set SSH remote
   git remote set-url origin git@github.com:zouzonghua/dotfiles.git
   ```

Installation fails safely when a managed path conflicts. Resolve the reported path explicitly, then rerun the command.

## Documentation

For detailed information on module mapping, advanced commands, and architecture, please refer to [AGENTS.md](./AGENTS.md).
