action "Install yabai and skhd"
brew install koekeishiya/formulae/yabai
brew install koekeishiya/formulae/skhd
sudo yabai --install-sa
ln "${HOME}/.dotfiles/yabai/.yabairc" "${HOME}/.yabairc"
ln "${HOME}/.dotfiles/yabai/.skhdrc" "${HOME}/.skhdrc"
brew services start skhd
brew services start yabai

ln -s $HOME/.dotfiles/tmux/.tmux.conf $HOME/.tmux.conf
ln -s $HOME/.dotfiles/git/.gitconfig $HOME/.gitconfig
ln -s $HOME/.dotfiles/config/kitty  $HOME/.config/kitty
ln -s $HOME/.dotfiles/zsh/.zshrc $HOME/.zshrc

