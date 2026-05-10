# dotfiles

Personal configuration files managed with **GNU Stow**.

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
   make install
   
   # Set SSH remote
   git remote set-url origin git@github.com:zouzonghua/dotfiles.git
   ```

## Documentation

For detailed information on module mapping, advanced commands, and architecture, please refer to [AGENTS.md](./AGENTS.md).
